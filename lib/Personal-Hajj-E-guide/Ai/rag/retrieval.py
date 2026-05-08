"""
retrieval.py — تحميل البيانات، query expansion، والاسترجاع الهجين (FAISS + BM25)
يعتمد على: text_utils, knowledge, location
"""

import json
import os
import sys as _sys
from pathlib import Path

_RAG_DIR = Path(__file__).resolve().parent
if str(_RAG_DIR) not in _sys.path:
    _sys.path.insert(0, str(_RAG_DIR))

import faiss
from sentence_transformers import SentenceTransformer

try:
    from rank_bm25 import BM25Okapi as BM25
    HAS_BM25 = True
except Exception:
    BM25 = None
    HAS_BM25 = False

from text_utils import (  # noqa: E402
    normalize_arabic, collapse_ws, tokenize_arabic,
    content_tokens, content_tokens_from_tokens, overlap_score,
    split_sentences, strip_headings, too_similar,
)
from knowledge import (  # noqa: E402
    CLARIFY_MSG, is_start_of_hajj_question, is_next_step_question,
)
from location import GPS_ZONE_BOOST, get_chunk_zone  # noqa: E402


# ── مسارات الملفات ─────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent
AI_DIR   = BASE_DIR.parent

INDEX_PATH  = AI_DIR / "Knowledge_base" / "processed_chunks" / "hajj_ar_faiss.index"
CHUNKS_PATH = AI_DIR / "Knowledge_base" / "processed_chunks" / "hajj_ar_chunks.jsonl"

MODEL_NAME           = "intfloat/multilingual-e5-small"
DEFAULT_EMBEDDING_DIR = AI_DIR / "models" / "multilingual-e5-small"
EMBEDDING_MODEL_PATH = os.getenv("EMBEDDING_MODEL_PATH", str(DEFAULT_EMBEDDING_DIR))
EMBEDDING_MODEL_ID   = os.getenv("EMBEDDING_MODEL_ID", MODEL_NAME)
HF_LOCAL_ONLY        = os.getenv("HF_LOCAL_ONLY", "1") == "1"
HF_CACHE_DIR         = os.getenv("HF_CACHE_DIR", "")


# ── ثوابت الاسترجاع ────────────────────────────────────────────────────────
TOP_K                 = 5
ALPHA                 = 0.3    # embedding weight vs BM25
SCORE_THRESHOLD       = 0.35
RERANK_CANDIDATE_MULT = 8
OVERLAP_BOOST         = 0.15
STAGE_BOOST           = 0.2
EXACT_STAGE_BOOST     = 1.5
NEXT_STAGE_BOOST      = 0.8

E5_QUERY_PREFIX   = "query: "
E5_PASSAGE_PREFIX = "passage: "

LOCATION_ALIASES = [
    "مني", "عرفات", "عرفه", "مزدلفه",
    "مكه", "المسجد الحرام", "البيت الحرام",
    "الجمرات", "جمرة العقبه",
]


# ── حالة مرحلية (تُبنى عند تحميل الـ chunks) ─────────────────────────────
_STAGE_SEQUENCE:     list[str]        = []
_STAGE_NORM_MAP:     dict[str, str]   = {}
_STAGE_ALIAS_MAP:    dict[str, str]   = {}
_STAGE_INFO:         dict[str, dict]  = {}
_PROCEDURAL_SEQUENCE: list[str]       = []


# ── E5 prefix ──────────────────────────────────────────────────────────────
def requires_e5_prefix(model_name: str = "") -> bool:
    name = model_name or EMBEDDING_MODEL_ID
    return "e5" in (name or "").lower()


def apply_query_prefix(text: str) -> str:
    return f"{E5_QUERY_PREFIX}{text}" if requires_e5_prefix() else text


def apply_passage_prefix(text: str) -> str:
    return f"{E5_PASSAGE_PREFIX}{text}" if requires_e5_prefix() else text


# ── تحميل البيانات ─────────────────────────────────────────────────────────
def load_chunks() -> list[dict]:
    chunks = []
    with CHUNKS_PATH.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            chunks.append(json.loads(line))
    build_stage_maps(chunks)
    return chunks


def chunk_text_display(chunk: dict) -> str:
    return chunk.get("text_display") or chunk.get("text") or ""


def chunk_text_for_embedding(chunk: dict) -> str:
    return chunk.get("text_for_embedding") or chunk.get("text") or ""


def build_stage_maps(chunks: list[dict]) -> None:
    _STAGE_SEQUENCE.clear()
    _PROCEDURAL_SEQUENCE.clear()
    _STAGE_NORM_MAP.clear()
    _STAGE_ALIAS_MAP.clear()
    _STAGE_INFO.clear()

    for chunk in chunks:
        meta        = chunk.get("metadata", {})
        stage_title = meta.get("stage_title") or chunk.get("stage_title") or ""
        if not stage_title:
            continue
        stage_norm = collapse_ws(normalize_arabic(stage_title))
        if stage_norm not in _STAGE_NORM_MAP:
            _STAGE_NORM_MAP[stage_norm] = stage_title
            _STAGE_SEQUENCE.append(stage_title)

        is_proc = bool(meta.get("is_procedural"))
        if is_proc and stage_title not in _PROCEDURAL_SEQUENCE:
            _PROCEDURAL_SEQUENCE.append(stage_title)

        _STAGE_INFO[stage_title] = {
            "phase_number":  meta.get("phase_number"),
            "phase_title":   meta.get("phase_title"),
            "is_procedural": is_proc,
        }

        for alias in LOCATION_ALIASES:
            alias_norm = collapse_ws(normalize_arabic(alias))
            if alias_norm and alias_norm in stage_norm and alias_norm not in _STAGE_ALIAS_MAP:
                _STAGE_ALIAS_MAP[alias_norm] = stage_title


# ── Inversion sniff ────────────────────────────────────────────────────────
# Catches a specific 2B-model failure mode: dropping or flipping a negation
# on a high-stakes fiqhi verb so the answer asserts the OPPOSITE of what the
# source says, while still passing token-overlap is_grounded (because the
# verb itself is in the context — just with a "لا" the LLM lost).
#
# Triggers when the answer contains one of these verbs in *positive* form
# (no negation in a ~30-char window before it) AND either:
#   * the verb doesn't appear in the retrieved context at all, or
#   * every occurrence in the context is preceded by a negation.
#
# Example caught: row 15 of the FAQ eval, "تُبطل الحج إذا لم يتم..." —
# source uses "تبطل" only in "لا تبطل" (not invalidated); the LLM dropped "لا".
import re as _re

_INVERSION_PRONE_VERBS = (
    "تبطل", "يبطل", "بطل",
    "يفسد", "تفسد",
    "يحرم", "تحرم",
    "يصح", "تصح",
    "يجوز", "تجوز",
)
_AR_NEG_PATTERN = _re.compile(r"\b(?:لا|ليس|لم|لن|غير)\b")
_INVERSION_NEG_WINDOW = 30  # chars before the verb to scan for negation


def _negated_before(text: str, idx: int, window: int = _INVERSION_NEG_WINDOW) -> bool:
    return bool(_AR_NEG_PATTERN.search(text[max(0, idx - window):idx]))


# Latin-script sniff. Triggers when an Arabic answer contains 3+ consecutive
# Latin letters — usually a sign the LLM glitched mid-token and emitted an
# English word like "then" / "and" inside an Arabic sentence (row 20 of the
# FAQ eval did this twice).
_LATIN_RUN_RE = _re.compile(r"[A-Za-z]{3,}")


def has_latin_codeswitch(answer: str) -> bool:
    """True if the answer contains a run of 3+ Latin letters. Cheap defense
    against the 2B model leaking English mid-Arabic-sentence."""
    if not answer:
        return False
    return bool(_LATIN_RUN_RE.search(answer))


# List-completeness sniff. When a source chunk presents a clearly enumerated
# list (a header line ending with ":" followed by short bullet lines) and
# the answer drops items, the LLM under-summarized. Catches row 1 (faraiz
# missing السعي) and row 16 (Arafat actions missing duaa/dhikr).
def _extract_list_items(chunk_text: str) -> list[str]:
    """Heuristically identify bullet-list items in a knowledge-base chunk."""
    items: list[str] = []
    in_list = False
    for raw in chunk_text.splitlines():
        ln = raw.strip()
        if not ln:
            continue
        if ln.startswith(("PHASE ", "STAGE:", "TYPE:", "STEP ")):
            in_list = False
            continue
        if ln.endswith(":") and len(ln) <= 50:
            in_list = True
            continue
        if in_list:
            # An item is short, has at most one comma/period (so prose
            # paragraphs don't get treated as bullets).
            if len(ln) <= 80 and ln.count(".") <= 1 and ln.count("،") <= 1:
                items.append(ln)
            else:
                in_list = False
    return items


def _first_content_token(text: str) -> str:
    toks = content_tokens(text)
    return toks[0] if toks else ""


def has_missing_list_items(
    answer: str,
    source_chunk: str,
    min_items: int = 3,
    miss_ratio: float = 0.25,
) -> bool:
    """True when the source has a list of `min_items`+ entries and the answer
    drops at least `miss_ratio` of them. Item presence is measured by the
    first content token of each item appearing (normalized) in the answer,
    so paraphrases like 'السعي' for 'السعي بين الصفا والمروة' still count."""
    items = _extract_list_items(source_chunk)
    if len(items) < min_items:
        return False

    a_norm = collapse_ws(normalize_arabic(answer))
    missing = 0
    counted = 0
    for item in items:
        first = _first_content_token(item)
        if not first:
            continue
        counted += 1
        if first not in a_norm:
            missing += 1

    if counted < min_items:
        return False
    return missing >= 1 and (missing / counted) >= miss_ratio


def has_inversion(answer: str, context: str) -> bool:
    """True when the answer flips a negation on a high-stakes verb relative
    to the retrieved context. See module-level comment for the failure mode
    this catches."""
    if not answer or not context:
        return False

    a = normalize_arabic(answer)
    c = normalize_arabic(context)

    for verb in _INVERSION_PRONE_VERBS:
        verb_re = _re.compile(r"\b" + _re.escape(verb) + r"\b")
        for m in verb_re.finditer(a):
            if _negated_before(a, m.start()):
                continue  # answer's occurrence is already negated — fine
            ctx_matches = list(verb_re.finditer(c))
            if not ctx_matches:
                # verb asserted positively but never in source → invented
                return True
            if all(_negated_before(c, cm.start()) for cm in ctx_matches):
                # source uses verb only with negation → answer dropped the لا
                return True
    return False


# ── Is Grounded ────────────────────────────────────────────────────────────
def is_grounded(answer: str, context: str) -> bool:
    if not answer or not context:
        return False
    a = collapse_ws(answer)
    c = collapse_ws(context)
    if a in c:
        return True
    ans_tokens = content_tokens(answer)
    ctx_tokens = set(content_tokens(context))
    if not ans_tokens or not ctx_tokens:
        return False
    overlap = sum(1 for t in ans_tokens if t in ctx_tokens)
    recall  = overlap / len(ans_tokens)
    # Thresholds bumped from 0.60/0.45 to 0.70/0.60 after the FAQ eval found
    # a logical-inversion case (Arafat sunset, row 15) that scraped past the
    # old 0.60 floor at recall=0.65. Tightening forces borderline answers
    # through the extractive fallback, which copies sentence-level from the
    # source instead of letting the LLM paraphrase into error.
    if recall >= 0.70:
        return True
    if len(ans_tokens) >= 12 and recall >= 0.60:
        return True
    return False


# ── Extractive Answer (fallback) ───────────────────────────────────────────
def extractive_answer(query: str, contexts: list[str]) -> str:
    q_expanded = expand_query(query)
    q_tokens   = content_tokens(q_expanded)
    tokens     = set(q_tokens)
    if not q_tokens:
        return CLARIFY_MSG

    rami_terms    = {"رمي", "الرمي", "يرمي", "الجمرات", "جمرة", "الجمار"}
    requires_rami = any(t in tokens for t in rami_terms)
    candidates: list[tuple[str, float]] = []

    for ctx in contexts:
        ctx_clean = strip_headings(ctx)
        for sent in split_sentences(ctx_clean):
            sent_tokens = set(content_tokens(sent))
            if not sent_tokens:
                continue
            if requires_rami and not any(k in sent for k in rami_terms):
                continue
            overlap = tokens & sent_tokens
            if not overlap:
                continue
            overlap_count = len(overlap)
            precision = overlap_count / max(len(sent_tokens), 1)
            recall    = overlap_count / max(len(tokens), 1)
            score     = (overlap_count * 2.0) + (recall * 1.5) + precision
            candidates.append((sent, score))

    if not candidates:
        return CLARIFY_MSG

    ranked   = sorted(candidates, key=lambda x: x[1], reverse=True)
    filtered: list[str] = []
    for s, _ in ranked:
        if requires_rami and not any(k in s for k in rami_terms):
            continue
        if all(not too_similar(s, prev) for prev in filtered):
            filtered.append(s)
        if len(filtered) >= 4:
            break

    return " ".join(filtered[:4]) if filtered else CLARIFY_MSG


# ── Query Expansion ────────────────────────────────────────────────────────
def expand_query(query: str) -> str:
    q = normalize_arabic(query)

    if is_start_of_hajj_question(q):
        q += " الاحرام من الميقات نية الحج التلبية لبيك اللهم حجا"

    if any(t in q for t in ["رمي", "الرمي", "الجمرات", "جمرة", "الجمار"]):
        q += " رمي الجمرات جمرة الجمار وقت الرمي بعد الزوال يوم النحر ايام التشريق"

    if "المواقيت الزمانيه" in q or "المواقيت المكانيه" in q:
        q += " المواقيت"

    if any(p in q for p in ["يوم عرفه ماذا افعل", "في عرفات اشلون", "خطوات يوم عرفه", "اشسوي في عرفات"]):
        q += " التوجه الى عرفات"

    if "جمرة العقبه" in q and any(t in q for t in ["بعد", "ماذا", "ما افعل", "ما اعمل"]):
        q += " الحلق والتقصير"

    # Air travel: route to the airport-specific chunk (الإحرام من المطار) which
    # explicitly covers wearing ihram BEFORE boarding + doing niyyah at miqat
    # alignment in flight. The generic miqat-list expansion below would otherwise
    # pump miqat tokens that out-rank the airport chunk and lose the
    # before-boarding step entirely.
    plane_query = any(t in q for t in [
        "بالطياره", "بالطائره", "بالطيره",
        "الطياره", "الطائره", "طائره", "طياره",
        "جوا", "بالجو", "مطار", "بالمطار",
    ])

    if plane_query:
        q += " الاحرام من المطار قبل الطائره لبس الاحرام في المطار نيه الاحرام"
    elif any(t in q for t in ["ميقات", "من اين احرم", "من وين احرم", "مكان الاحرام"]):
        q += " المواقيت المكانيه ذو الحليفه الجحفه يلملم"

    if any(t in q for t in ["اقول", "اقوله", "الكلام"]) and any(
        t in q for t in ["احرام", "محرم", "احرم", "نسك", "احرمت"]
    ):
        q += " التلبيه لبيك اللهم لبيك لبيك لا شريك لك لبيك ان الحمد والنعمه لك والملك"

    if any(t in q for t in ["ممنوع", "محظور", "يحرم", "لا يجوز", "ما يجوز", "محظورات"]) and any(
        t in q for t in ["احرام", "محرم", "احرم"]
    ):
        q += " محظورات الاحرام لبس المخيط الطيب الشعر الاظفار"

    if any(t in q for t in ["حصاه", "حصاة", "حصى", "حصيات"]) and any(
        t in q for t in ["مزدلفه", "مزدلفة", "اجمع", "اخذ", "نجمع"]
    ):
        q += " مزدلفه جمع حصيات رمي جمره العقبه التوجه الى مزدلفه"

    if any(t in q for t in ["اسوي", "افعل", "اعمل"]) and any(
        t in q for t in ["عرفه", "عرفة", "عرفات"]
    ):
        q += " الوقوف بعرفه الدعاء الذكر يوم التاسع كيف يقضي الحاج يوم عرفه"

    if any(t in q for t in ["بعد عرفه", "بعد عرفة", "بعد الوقوف", "بعد عرفات"]):
        q += " مزدلفه التوجه الى مزدلفه المبيت بعد غروب الشمس ينفر الحجاج"

    if any(t in q for t in ["بعد الطواف", "بعد طواف", "انتهيت من الطواف", "خلصت الطواف"]):
        q += " ركعتي الطواف مقام ابراهيم السعي بين الصفا والمروه طواف القدوم"

    if any(t in q for t in ["ما وقفت", "لم اقف", "لو ما وقفت", "ما وصلت عرفه",
                             "فاتني عرفه", "ما وصلت عرفات", "فات الوقوف", "فات الحج"]):
        q += " الوقوف بعرفه ركن من اركان الحج لا يصح الحج بدونه"

    return q


# ── Stage inference ────────────────────────────────────────────────────────
def infer_current_stage(query: str, prefer_procedural: bool = True) -> str:
    q = collapse_ws(normalize_arabic(query))
    best       = ""
    best_score = -1

    for stage_title, info in _STAGE_INFO.items():
        stage_norm = collapse_ws(normalize_arabic(stage_title))
        if stage_norm and stage_norm in q:
            score = len(stage_norm)
            if prefer_procedural and info.get("is_procedural"):
                score += 1000
            if score > best_score:
                best       = stage_title
                best_score = score

    for alias_norm, stage_title in _STAGE_ALIAS_MAP.items():
        if alias_norm in q:
            score = len(alias_norm)
            if prefer_procedural and _STAGE_INFO.get(stage_title, {}).get("is_procedural"):
                score += 1000
            if score > best_score:
                best       = stage_title
                best_score = score

    return best


def infer_next_stage(current_stage: str) -> str:
    if not current_stage:
        return ""
    if current_stage in _PROCEDURAL_SEQUENCE:
        idx = _PROCEDURAL_SEQUENCE.index(current_stage)
        if idx + 1 < len(_PROCEDURAL_SEQUENCE):
            return _PROCEDURAL_SEQUENCE[idx + 1]
    if current_stage in _STAGE_SEQUENCE:
        idx = _STAGE_SEQUENCE.index(current_stage)
        if idx + 1 < len(_STAGE_SEQUENCE):
            return _STAGE_SEQUENCE[idx + 1]
    return ""


# ── Overview chunks (فرائض / خطوات) ───────────────────────────────────────
def get_hajj_overview_chunks(chunks: list[dict], faraiz_only: bool = False) -> list[tuple[int, float]]:
    faraiz = [
        c for c in chunks
        if c.get("metadata", {}).get("phase_number", -1) == 0
        and c.get("metadata", {}).get("stage_title", "") in ("أركان الحج", "")
    ]
    faraiz = sorted(faraiz, key=lambda c: c.get("id", 99))[:1]

    if faraiz_only:
        return [(c["id"], 3.0) for c in faraiz]

    JOURNEY_PHASES = [2, 4, 5, 6, 7, 8, 9, 10]
    by_phase: dict[int, dict] = {}
    for c in chunks:
        ph = c.get("metadata", {}).get("phase_number", -1)
        if ph in JOURNEY_PHASES:
            if ph not in by_phase or c.get("id", 99) < by_phase[ph].get("id", 99):
                by_phase[ph] = c

    journey_chunks = [by_phase[ph] for ph in JOURNEY_PHASES if ph in by_phase]
    return [(c["id"], 2.0) for c in journey_chunks[:7]]


# ── Hybrid Retrieve ────────────────────────────────────────────────────────
def hybrid_retrieve(
    chunks:    list[dict],
    index,
    query:     str,
    model=None,
    user_zone: str = "",
) -> list[tuple[int, float]]:

    corpus_tokens = [tokenize_arabic(chunk_text_for_embedding(c)) for c in chunks]
    q_expanded    = expand_query(query)
    q_norm        = collapse_ws(normalize_arabic(q_expanded))

    prefer_procedural = is_next_step_question(q_norm)
    current_stage     = infer_current_stage(q_norm, prefer_procedural=prefer_procedural)
    next_stage        = infer_next_stage(current_stage) if prefer_procedural else ""
    next_stage_norm   = collapse_ws(normalize_arabic(next_stage))

    if model is None:
        if HF_LOCAL_ONLY and not Path(EMBEDDING_MODEL_PATH).exists():
            raise RuntimeError(
                f"Embedding model not found at {EMBEDDING_MODEL_PATH}. "
                "Place it in the models folder or set EMBEDDING_MODEL_PATH."
            )
        try:
            model = SentenceTransformer(
                EMBEDDING_MODEL_PATH,
                cache_folder=HF_CACHE_DIR or None,
                local_files_only=HF_LOCAL_ONLY,
            )
        except Exception as exc:
            raise RuntimeError("Embedding model not found. Set EMBEDDING_MODEL_PATH.") from exc

    q_emb = model.encode([apply_query_prefix(q_expanded)], convert_to_numpy=True, normalize_embeddings=True)
    emb_scores, emb_indices = index.search(q_emb, TOP_K * RERANK_CANDIDATE_MULT)
    emb_score_by_idx = {int(idx): float(emb_scores[0][r]) for r, idx in enumerate(emb_indices[0])}

    q_tokens  = tokenize_arabic(q_expanded)
    q_content = content_tokens_from_tokens(q_tokens)

    if HAS_BM25:
        bm25_obj    = BM25(corpus_tokens)
        bm25_scores = bm25_obj.get_scores(q_tokens)
    else:
        bm25_scores = [overlap_score(q_content, content_tokens_from_tokens(t)) for t in corpus_tokens]

    max_bm25  = max(bm25_scores) if bm25_scores else 1.0
    bm25_norm = [s / max_bm25 if max_bm25 > 0 else 0.0 for s in bm25_scores]

    candidate_pool    = TOP_K * RERANK_CANDIDATE_MULT
    top_bm25_indices  = sorted(range(len(bm25_norm)), key=lambda i: bm25_norm[i], reverse=True)[:candidate_pool]
    candidate_indices = set(emb_indices[0][:candidate_pool]) | set(top_bm25_indices)

    for idx, chunk in enumerate(chunks):
        stage_norm = collapse_ws(normalize_arabic(
            chunk.get("metadata", {}).get("stage_title") or chunk.get("stage_title") or ""
        ))
        if stage_norm and stage_norm in q_norm:
            candidate_indices.add(idx)

    combined: dict[int, float] = {}
    for idx in candidate_indices:
        emb_score  = emb_score_by_idx.get(idx, 0.0)
        base_score = ALPHA * emb_score + (1 - ALPHA) * bm25_norm[idx]

        doc_content   = content_tokens_from_tokens(corpus_tokens[idx])
        lexical       = overlap_score(q_content, doc_content)

        stage_title   = chunks[idx].get("metadata", {}).get("stage_title") or chunks[idx].get("stage_title") or ""
        stage_tokens  = content_tokens(stage_title)
        stage_overlap = overlap_score(q_content, stage_tokens)
        stage_norm    = collapse_ws(normalize_arabic(stage_title))
        stage_exact      = 1.0 if stage_norm and stage_norm in q_norm else 0.0
        next_stage_exact = 1.0 if next_stage_norm and stage_norm == next_stage_norm else 0.0

        gps_boost = GPS_ZONE_BOOST if user_zone and get_chunk_zone(chunks[idx]) == user_zone else 1.0

        combined[idx] = (
            base_score
            + OVERLAP_BOOST    * lexical
            + STAGE_BOOST      * stage_overlap
            + EXACT_STAGE_BOOST * stage_exact
            + NEXT_STAGE_BOOST  * next_stage_exact
        ) * gps_boost

    ranked  = sorted(combined.items(), key=lambda x: x[1], reverse=True)
    results = [(idx, score) for idx, score in ranked if score >= SCORE_THRESHOLD][:TOP_K]
    return results if results else ranked[:TOP_K]
