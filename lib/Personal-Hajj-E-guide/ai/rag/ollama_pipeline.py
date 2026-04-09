import json
import math
import os
import re
import argparse
from pathlib import Path

import faiss
import requests
from sentence_transformers import SentenceTransformer

try:
    from rank_bm25 import BM25Okapi as BM25
    HAS_BM25 = True
except Exception:
    BM25 = None
    HAS_BM25 = False


BASE_DIR = Path(__file__).resolve().parent
AI_DIR = BASE_DIR.parent
INDEX_PATH = AI_DIR / "Knowledge_base" / "processed_chunks" / "hajj_ar_faiss.index"
CHUNKS_PATH = AI_DIR / "Knowledge_base" / "processed_chunks" / "hajj_ar_chunks.jsonl"
OUTPUT_PATH = AI_DIR / "tests" / "data" / "last_answer.txt"
MODEL_NAME = "intfloat/multilingual-e5-small"
DEFAULT_EMBEDDING_DIR = AI_DIR / "models" / "multilingual-e5-small"
EMBEDDING_MODEL_PATH = os.getenv("EMBEDDING_MODEL_PATH", str(DEFAULT_EMBEDDING_DIR))
EMBEDDING_MODEL_ID = os.getenv("EMBEDDING_MODEL_ID", MODEL_NAME)
HF_LOCAL_ONLY = os.getenv("HF_LOCAL_ONLY", "1") == "1"
HF_CACHE_DIR = os.getenv("HF_CACHE_DIR", "")
USE_FALLBACK = os.getenv("USE_FALLBACK", "1") == "1"

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "silma-kashif:2b")

TOP_K = 5
ALPHA = 0.3  # embedding weight vs BM25 (0..1)
SCORE_THRESHOLD = 0.15
CONTEXT_SEPARATOR = "\n\n---\n\n"

# ملخص ثابت يُضاف أول الـ context لأسئلة "خطوات الحج" حتى لا يخلط المودل الصغير الترتيب
HAJJ_JOURNEY_SUMMARY = """خطوات الحج بالترتيب الزمني:
(1) الإحرام من الميقات
(2) طواف القدوم والسعي بين الصفا والمروة
(3) التوجه إلى منى يوم التروية — 8 ذي الحجة
(4) الوقوف بعرفة — 9 ذي الحجة من الزوال حتى الغروب
(5) المبيت بمزدلفة وجمع الحصى
(6) رمي جمرة العقبة ثم الحلق والنحر ثم طواف الإفاضة — يوم النحر 10 ذي الحجة
(7) أيام التشريق والمبيت بمنى ورمي الجمرات الثلاث — 11-13 ذي الحجة
(8) طواف الوداع عند المغادرة"""
RERANK_CANDIDATE_MULT = 8
OVERLAP_BOOST = 0.15
STAGE_BOOST = 0.2
EXACT_STAGE_BOOST = 1.5
NEXT_STAGE_BOOST = 0.8
E5_QUERY_PREFIX = "query: "
E5_PASSAGE_PREFIX = "passage: "

LOCATION_ALIASES = [
    "مني",
    "عرفات",
    "عرفه",
    "مزدلفه",
    "مكه",
    "المسجد الحرام",
    "البيت الحرام",
    "الجمرات",
    "جمرة العقبه",
]

NEXT_STEP_TERMS = [
    "وش الخطوه الجايه",
    "وش الخطوه التاليه",
    "الخطوه الجايه",
    "الخطوه التاليه",
    "وش التالي",
    "وش بعد",
    "وش اسوي بعد",
    "وش اعمل بعد",
    "بعدها",
]

_STAGE_SEQUENCE = []
_STAGE_NORM_MAP = {}
_STAGE_ALIAS_MAP = {}
_STAGE_INFO = {}
_PROCEDURAL_SEQUENCE = []


# Answer behavior
CLARIFY_MSG = "لم افهم ما تعني بالضبط، هل يمكنك اعادة صياغة السؤال؟"
FOLLOWUP_MSG = "هل يمكنني مساعدتك في شي اخر؟"

# =========================
# Prompts
# =========================
SYSTEM_PROMPT = """أنت مرشد حج متخصص، تحدّث مع الحاج كصديق مرافق له في رحلته.

أسلوبك:
- رحّب بالحاج في أول رد فقط بـ "حياك الله يا حاج" أو "أهلاً وسهلاً يا حاج"
- استخدم كلمات مثل "تفضل" و"بكل سرور" و"طبعاً" عند الإجابة
- في نهاية كل إجابة اقترح سؤالاً واحداً متعلقاً — اكتبه كسطر أخير بصيغة: "💡 هل تبي أعرّفك على ..."  ولا تجاوب عليه

قواعد صارمة:
- أجب فقط مما في النص المقدم — لا تزيد ولا تكرر المعلومة بصياغتين
- إذا كان السؤال عن فرائض الحج أو أركانه تحديداً، اذكرها بالترتيب: (1) الإحرام (2) الوقوف بعرفة (3) طواف الإفاضة (4) السعي بين الصفا والمروة
- إذا كان السؤال عن خطوات الحج أو مراحله، اعرض الرحلة بهذا الترتيب الزمني الثابت ولا تغيّره: (1) الإحرام (2) الطواف والسعي (3) التوجه إلى منى يوم التروية (8 ذي الحجة) (4) الوقوف بعرفة (9 ذي الحجة) (5) المبيت بمزدلفة (6) رمي جمرة العقبة والنحر والحلق (7) طواف الإفاضة (8) أيام التشريق ورمي الجمرات (9) طواف الوداع
- عند عرض الخطوات لا تعكس الترتيب ولا تقدّم خطوة متأخرة قبل سابقتها
- إذا كان السؤال عن خطوات اعرضها بالتسلسل: (1) ثم (2) ثم (3) من البداية
- لا تذكر معلومة غير موجودة في النص
- إذا لم تجد الإجابة قل: "ما عندي هذي المعلومة في دليلك الحالي"
- لا تخمّن ولا تضف من عندك

المرحلة الحالية: {phase}
نوع المحتوى: {content_type}
"""

USER_PROMPT = """النص المرجعي:
{context}

سؤال الحاج: {question}
الإجابة:"""

REFUSAL_MARKERS = [
    "اعتذر",
    "اعتذار",
    "لا استطيع",
    "لا أستطيع",
    "لا يمكنني",
    "غير واضحة",
    "مهينة",
    "لا اقدر",
]


def requires_e5_prefix(model_name: str = "") -> bool:
    name = model_name or EMBEDDING_MODEL_ID
    return "e5" in (name or "").lower()


def apply_query_prefix(text: str) -> str:
    return f"{E5_QUERY_PREFIX}{text}" if requires_e5_prefix(EMBEDDING_MODEL_ID) else text


def apply_passage_prefix(text: str) -> str:
    return f"{E5_PASSAGE_PREFIX}{text}" if requires_e5_prefix(EMBEDDING_MODEL_ID) else text


def normalize_arabic(text: str) -> str:
    text = re.sub(r"[إأآا]", "ا", text)
    text = re.sub(r"ى", "ي", text)
    text = re.sub(r"ؤ", "و", text)
    text = re.sub(r"ئ", "ي", text)
    text = re.sub(r"ة", "ه", text)
    text = re.sub(r"ـ", "", text)
    text = re.sub(r"[ًٌٍَُِّْ]", "", text)
    return text


def collapse_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def tokenize_arabic(text: str):
    text = normalize_arabic(text)
    text = re.sub(r"[؟!،؛\.\"«»\(\)\[\]']", " ", text)
    text = re.sub(r"[^\u0600-\u06FF0-9A-Za-z\s]", " ", text)
    return [t for t in text.split() if t]


AR_STOPWORDS = {
    "في", "من", "على", "الى", "الي", "عن", "ما", "هو", "هي", "هذا", "هذه",
    "ذلك", "تلك", "ثم", "او", "و", "الذي", "التي", "ان", "لا", "لم", "لن",
    "قد", "بعد", "قبل", "مع", "بين", "كل", "كان", "كانت", "يكون", "تكون",
    "اذا", "عند", "حتى", "كما", "اي", "تم", "فان",
}


def content_tokens(text: str):
    tokens = tokenize_arabic(text)
    return [t for t in tokens if len(t) > 1 and t not in AR_STOPWORDS]


def content_tokens_from_tokens(tokens):
    return [t for t in tokens if len(t) > 1 and t not in AR_STOPWORDS]


def overlap_score(query_tokens, doc_tokens) -> float:
    if not query_tokens or not doc_tokens:
        return 0.0
    doc_set = set(doc_tokens)
    overlap = sum(1 for t in query_tokens if t in doc_set)
    return overlap / max(len(query_tokens), 1)


def looks_like_refusal(text: str) -> bool:
    t = collapse_ws(normalize_arabic(text or ""))
    for marker in REFUSAL_MARKERS:
        if normalize_arabic(marker) in t:
            return True
    return False


def ensure_followup(answer: str) -> str:
    """لا تضف رسالة ثابتة — البرومبت يطلب من الـ LLM يقترح سؤالاً بنفسه"""
    return answer.rstrip() if answer else ""


def split_sentences(text: str):
    parts = re.split(r"(?<=[\.!?؟])\s+", text)
    return [p.strip() for p in parts if p.strip()]


def strip_headings(text: str) -> str:
    import re as _re
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    cleaned = []
    for ln in lines:
        if ln.startswith("PHASE ") or ln.startswith("STAGE:") or ln.startswith("TYPE:"):
            continue
        # أزل علامات STEP N (الخطوة X): من الأسطر
        ln = _re.sub(r"^STEP\s+\d+\s*\([^)]*\)\s*:?\s*", "", ln).strip()
        if not ln:
            continue
        cleaned.append(ln)
    return " ".join(cleaned).strip()


def dedupe_sentences(sentences):
    seen = set()
    deduped = []
    for s in sentences:
        key = collapse_ws(s)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(s)
    return deduped


def too_similar(a: str, b: str, threshold: float = 0.6) -> bool:
    ta = set(tokenize_arabic(a))
    tb = set(tokenize_arabic(b))
    if not ta or not tb:
        return False
    jaccard = len(ta & tb) / len(ta | tb)
    return jaccard >= threshold


def extractive_answer(query: str, contexts):
    q_expanded = expand_query(query)
    q_tokens = content_tokens(q_expanded)
    tokens = set(q_tokens)
    if not q_tokens:
        return CLARIFY_MSG

    rami_terms = {"رمي", "الرمي", "يرمي", "الجمرات", "جمرة", "الجمار"}
    requires_rami = any(t in tokens for t in rami_terms)
    candidates = []

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
            recall = overlap_count / max(len(tokens), 1)
            score = (overlap_count * 2.0) + (recall * 1.5) + precision
            candidates.append((sent, score))

    if not candidates:
        return CLARIFY_MSG

    ranked = sorted(candidates, key=lambda x: x[1], reverse=True)
    filtered = []
    for s, _score in ranked:
        if requires_rami and not any(k in s for k in rami_terms):
            continue
        if all(not too_similar(s, prev) for prev in filtered):
            filtered.append(s)
        if len(filtered) >= 4:
            break

    if not filtered:
        return CLARIFY_MSG

    return " ".join(filtered[:4])


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
    recall = overlap / len(ans_tokens)

    if recall >= 0.60:
        return True
    if len(ans_tokens) >= 12 and recall >= 0.45:
        return True
    return False


def needs_detailed_answer(query: str) -> bool:
    q = collapse_ws(normalize_arabic(query))
    markers = [
        "مناسك",
        "انواع",
        "الخطوات",
        "خطوات",
        "شرح",
        "تفصيل",
        "كيف",
        "ماهي",
        "ما هو",
        "ما هي",
    ]
    return any(m in q for m in markers)


def load_chunks():
    chunks = []
    with CHUNKS_PATH.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            chunks.append(json.loads(line))
    build_stage_maps(chunks)
    return chunks


def chunk_text_display(chunk) -> str:
    return chunk.get("text_display") or chunk.get("text") or ""


def chunk_text_for_embedding(chunk) -> str:
    text = chunk.get("text_for_embedding") or chunk.get("text") or ""
    return text


def build_stage_maps(chunks):
    _STAGE_SEQUENCE.clear()
    _PROCEDURAL_SEQUENCE.clear()
    _STAGE_NORM_MAP.clear()
    _STAGE_ALIAS_MAP.clear()
    _STAGE_INFO.clear()

    for chunk in chunks:
        meta = chunk.get("metadata", {})
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
            "phase_number": meta.get("phase_number"),
            "phase_title": meta.get("phase_title"),
            "is_procedural": is_proc,
        }

        for alias in LOCATION_ALIASES:
            alias_norm = collapse_ws(normalize_arabic(alias))
            if alias_norm and alias_norm in stage_norm and alias_norm not in _STAGE_ALIAS_MAP:
                _STAGE_ALIAS_MAP[alias_norm] = stage_title


OFF_TOPIC_MSG = "ما عندي هذي المعلومة في دليل الحج. دليلي يغطي مناسك الحج والأحكام الفقهية المتعلقة بها."

# كلمات تدل على أسئلة إدارية أو خارج نطاق المناسك
_OFF_TOPIC_MARKERS = [
    # إدارية - حجز وتسجيل
    "ابشر", "أبشر", "تسجيل في ابشر", "تصريح حج", "باقة الحج",
    "سعر الباقة", "سعر باقه", "حجز طيران", "تذكرة طيران", "تأشيرة",
    "تاشيره", "رسوم الحج", "رسوم التسجيل", "متى يبدأ التسجيل",
    "منصة نسك", "تطبيق نسك", "فيزا الحج",
    # خارج الحج كليّاً
    "سعر صرف", "سعر الدولار", "ضريبة", "جامعة", "رخصة قيادة",
    "مستشفى منى", "رقم مستشفى", "رقم الطوارئ", "رقم الشرطة",
    "طقس مكة", "درجة الحرارة",
    # أسئلة فقهية غير مغطاة في الـ KB
    "بدون محرم", "بغير محرم", "بلا محرم",
    "المرأة تحج وحدها", "تحج بدون محرم",
    # فوت عرفة — حكم غير موجود في الـ KB
    "لو ما وقفت في عرفه", "لو ما وقفت في عرفة", "لو ما وقفت في عرفات",
    "اذا ما وقفت في عرفه", "اذا فاتني عرفه", "اذا فات الوقوف",
]

def is_off_topic(query: str) -> bool:
    q = collapse_ws(normalize_arabic(query))
    return any(collapse_ws(normalize_arabic(m)) in q for m in _OFF_TOPIC_MARKERS)


def is_faraiz_only_question(query: str) -> bool:
    """سؤال عن الفرائض/الأركان فقط — بدون طلب خطوات كاملة."""
    q = collapse_ws(normalize_arabic(query))
    faraiz_markers = [
        "فرائض الحج", "فرايض الحج", "اركان الحج", "أركان الحج",
        "ما هي فرائض", "ما هي اركان", "ايش فرائض", "ايش اركان",
        "وش فرائض الحج", "وش اركان الحج",
    ]
    steps_markers = [
        "خطوات", "مراحل", "خطوه", "خطوة", "كيف اودي", "كيف اؤدي",
        "من البداية", "من وين ابدا", "كيف ابدا",
    ]
    has_faraiz = any(m in q for m in faraiz_markers)
    has_steps = any(m in q for m in steps_markers)
    return has_faraiz and not has_steps


def is_start_of_hajj_question(query: str) -> bool:
    q = collapse_ws(normalize_arabic(query))
    markers = [
        "اول خطوة", "اول خطوه", "بداية الحج", "بدايه الحج",
        "من وين ابدا", "كيف ابدا الحج", "بداية المناسك",
        "خطوات الحج", "مراحل الحج", "كيف اؤدي الحج", "كيف اودي الحج",
        "وش اول", "اول شي", "خطوات اداء الحج",
        "كيف ابدا", "من وين ابدا", "وش اسوي اول",
        "ما هي خطوات الحج", "ما هو خطوات الحج",
        # فرائض وأركان الحج
        "فرائض الحج", "فرايض الحج", "اركان الحج", "أركان الحج",
        "ما هي فرائض", "ما هي اركان", "ايش فرائض", "ايش اركان",
        "وش فرائض الحج", "وش اركان الحج",
    ]
    if any(m in q for m in markers):
        return True
    if "اول" in q and ("خطوة" in q or "خطوه" in q) and ("الحج" in q or "مناسك" in q):
        return True
    return False


def is_next_step_question(query: str) -> bool:
    q = collapse_ws(normalize_arabic(query))
    if is_start_of_hajj_question(q):
        return False
    return any(term in q for term in NEXT_STEP_TERMS)


def infer_current_stage(query: str, prefer_procedural: bool = True) -> str:
    q = collapse_ws(normalize_arabic(query))
    best = ""
    best_score = -1

    for stage_title, info in _STAGE_INFO.items():
        stage_norm = collapse_ws(normalize_arabic(stage_title))
        if stage_norm and stage_norm in q:
            score = len(stage_norm)
            if prefer_procedural and info.get("is_procedural"):
                score += 1000
            if score > best_score:
                best = stage_title
                best_score = score

    for alias_norm, stage_title in _STAGE_ALIAS_MAP.items():
        if alias_norm in q:
            score = len(alias_norm)
            if prefer_procedural and _STAGE_INFO.get(stage_title, {}).get("is_procedural"):
                score += 1000
            if score > best_score:
                best = stage_title
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


def expand_query(query: str) -> str:
    q = normalize_arabic(query)

    if is_start_of_hajj_question(q):
        q = q + " الاحرام من الميقات نية الحج التلبية لبيك اللهم حجا"

    if any(t in q for t in ["رمي", "الرمي", "الجمرات", "جمرة", "الجمار"]):
        q = q + " رمي الجمرات جمرة الجمار وقت الرمي بعد الزوال يوم النحر ايام التشريق"

    if "المواقيت الزمانيه" in q or "المواقيت المكانيه" in q:
        q = q + " المواقيت"

    if any(phrase in q for phrase in ["يوم عرفه ماذا افعل", "في عرفات اشلون", "خطوات يوم عرفه", "اشسوي في عرفات"]):
        q = q + " التوجه الى عرفات"

    if "جمرة العقبه" in q and any(t in q for t in ["بعد", "ماذا", "ما افعل", "ما اعمل"]):
        q = q + " الحلق والتقصير"

    # ميقات الإحرام → المواقيت المكانية
    if any(t in q for t in ["ميقات", "من اين احرم", "من وين احرم", "مكان الاحرام"]):
        q = q + " المواقيت المكانيه ذو الحليفه الجحفه يلملم"

    # التلبية: ماذا يقول عند الإحرام — نص مطابق لـ chunk 5 بالضبط
    if any(t in q for t in ["اقول", "اقوله", "الكلام"]) and any(
        t in q for t in ["احرام", "محرم", "احرم", "نسك", "احرمت"]
    ):
        q = q + " التلبيه لبيك اللهم لبيك لبيك لا شريك لك لبيك ان الحمد والنعمه لك والملك"

    # محظورات الإحرام: ما الممنوع على المحرم
    if any(t in q for t in ["ممنوع", "محظور", "يحرم", "لا يجوز", "ما يجوز", "محظورات"]) and any(
        t in q for t in ["احرام", "محرم", "احرم"]
    ):
        q = q + " محظورات الاحرام لبس المخيط الطيب الشعر الاظفار"

    # جمع الحصى في مزدلفة
    if any(t in q for t in ["حصاه", "حصاة", "حصى", "حصيات"]) and any(
        t in q for t in ["مزدلفه", "مزدلفة", "اجمع", "اخذ", "نجمع"]
    ):
        q = q + " مزدلفه جمع حصيات رمي جمره العقبه التوجه الى مزدلفه"

    # ماذا يفعل في عرفة → عرفة
    if any(t in q for t in ["اسوي", "افعل", "اعمل"]) and any(
        t in q for t in ["عرفه", "عرفة", "عرفات"]
    ):
        q = q + " الوقوف بعرفه الدعاء الذكر يوم التاسع كيف يقضي الحاج يوم عرفه"

    # بعد عرفة/عرفات → مزدلفة (يشمل "عرفات" اللي ما تنرمل لـ "عرفه")
    if any(t in q for t in ["بعد عرفه", "بعد عرفة", "بعد الوقوف", "بعد عرفات"]):
        q = q + " مزدلفه التوجه الى مزدلفه المبيت بعد غروب الشمس ينفر الحجاج"

    # بعد الطواف → ركعتان + سعي
    if any(t in q for t in ["بعد الطواف", "بعد طواف", "انتهيت من الطواف", "خلصت الطواف"]):
        q = q + " ركعتي الطواف مقام ابراهيم السعي بين الصفا والمروه طواف القدوم"

    # فوت الوقوف بعرفة — غير موجود في الـ KB → يُضاف للـ off-topic تلقائياً بالـ extractive
    if any(t in q for t in ["ما وقفت", "لم اقف", "لو ما وقفت", "ما وصلت عرفه",
                             "فاتني عرفه", "ما وصلت عرفات", "فات الوقوف", "فات الحج"]):
        q = q + " الوقوف بعرفه ركن من اركان الحج لا يصح الحج بدونه"

    return q


def get_hajj_overview_chunks(chunks, faraiz_only: bool = False) -> list:
    """
    عند سؤال خطوات الحج: أرجع chunks تغطي الرحلة الزمنية كاملة.
    عند سؤال فرائض/أركان الحج فقط: أرجع chunk الفرائض وحده.

    الترتيب الزمني للحج:
      Phase 0 (أركان) → Phase 2 (إحرام) → Phase 4 (طواف+سعي)
      → Phase 5 (منى) → Phase 6 (عرفة) → Phase 7 (مزدلفة)
      → Phase 8 (يوم النحر) → Phase 9 (التشريق) → Phase 10 (وداع)
    """
    # chunk الفرائض (phase 0, id=0)
    faraiz = [c for c in chunks if c.get("metadata", {}).get("phase_number", -1) == 0
              and c.get("metadata", {}).get("stage_title", "") in ("أركان الحج", "")]
    faraiz = sorted(faraiz, key=lambda c: c.get("id", 99))[:1]

    if faraiz_only:
        return [(c["id"], 3.0) for c in faraiz]

    # أول chunk إجرائي من كل phase رئيسية بالترتيب الزمني
    JOURNEY_PHASES = [2, 4, 5, 6, 7, 8, 9, 10]
    by_phase: dict = {}
    for c in chunks:
        ph = c.get("metadata", {}).get("phase_number", -1)
        if ph in JOURNEY_PHASES:
            if ph not in by_phase:
                by_phase[ph] = c
            elif c.get("id", 99) < by_phase[ph].get("id", 99):
                by_phase[ph] = c

    journey_chunks = [by_phase[ph] for ph in JOURNEY_PHASES if ph in by_phase]

    # لسؤال الخطوات الكامل: أرجع فقط chunks الرحلة الزمنية بدون chunk الفرائض
    # (chunk الفرائض بترتيبه الفقهي يخلط الـ LLM عن الترتيب الزمني)
    result = [(c["id"], 2.0) for c in journey_chunks[:7]]
    return result


def hybrid_retrieve(chunks, index, query: str, model=None):
    corpus_tokens = [tokenize_arabic(chunk_text_for_embedding(c)) for c in chunks]
    q_expanded = expand_query(query)
    q_norm = collapse_ws(normalize_arabic(q_expanded))
    prefer_procedural = is_next_step_question(q_norm)
    current_stage = infer_current_stage(q_norm, prefer_procedural=prefer_procedural)
    next_stage = infer_next_stage(current_stage) if prefer_procedural else ""
    next_stage_norm = collapse_ws(normalize_arabic(next_stage))

    if model is None:
        cache_folder = HF_CACHE_DIR or None
        model_path = EMBEDDING_MODEL_PATH
        if HF_LOCAL_ONLY and model_path and not Path(model_path).exists():
            raise RuntimeError(
                f"Embedding model not found at {model_path}. Place it in {DEFAULT_EMBEDDING_DIR} or set EMBEDDING_MODEL_PATH. "
                "If you want online download, set HF_LOCAL_ONLY=0."
            )
        try:
            model = SentenceTransformer(
                model_path,
                cache_folder=cache_folder,
                local_files_only=HF_LOCAL_ONLY,
            )
        except Exception as exc:
            raise RuntimeError(
                "Embedding model not found locally. Place it in the default models folder or set EMBEDDING_MODEL_PATH. "
                "If you want online download, set HF_LOCAL_ONLY=0."
            ) from exc

    q_emb = model.encode([apply_query_prefix(q_expanded)], convert_to_numpy=True, normalize_embeddings=True)
    emb_scores, emb_indices = index.search(q_emb, TOP_K * RERANK_CANDIDATE_MULT)
    emb_score_by_idx = {}
    for rank, idx in enumerate(emb_indices[0], 1):
        emb_score_by_idx[idx] = float(emb_scores[0][rank - 1])

    q_tokens = tokenize_arabic(q_expanded)
    q_content = content_tokens_from_tokens(q_tokens)

    if HAS_BM25:
        bm25 = BM25(corpus_tokens)
        bm25_scores = bm25.get_scores(q_tokens)
    else:
        bm25_scores = [overlap_score(q_content, content_tokens_from_tokens(toks)) for toks in corpus_tokens]

    max_bm25 = max(bm25_scores) if bm25_scores else 1.0
    bm25_norm = [s / max_bm25 if max_bm25 > 0 else 0.0 for s in bm25_scores]

    candidate_pool = TOP_K * RERANK_CANDIDATE_MULT
    top_bm25_indices = sorted(range(len(bm25_norm)), key=lambda i: bm25_norm[i], reverse=True)[:candidate_pool]
    candidate_indices = set(emb_indices[0][:candidate_pool]) | set(top_bm25_indices)

    for idx, chunk in enumerate(chunks):
        stage_title = chunk.get("metadata", {}).get("stage_title") or chunk.get("stage_title") or ""
        stage_norm = collapse_ws(normalize_arabic(stage_title))
        if stage_norm and stage_norm in q_norm:
            candidate_indices.add(idx)

    combined = {}
    for idx in candidate_indices:
        emb_score = emb_score_by_idx.get(idx, 0.0)
        base_score = ALPHA * emb_score + (1 - ALPHA) * bm25_norm[idx]

        doc_content = content_tokens_from_tokens(corpus_tokens[idx])
        lexical = overlap_score(q_content, doc_content)

        stage_title = chunks[idx].get("metadata", {}).get("stage_title") or chunks[idx].get("stage_title") or ""
        stage_tokens = content_tokens(stage_title)
        stage_overlap = overlap_score(q_content, stage_tokens)
        stage_norm = collapse_ws(normalize_arabic(stage_title))
        stage_exact = 1.0 if stage_norm and stage_norm in q_norm else 0.0
        next_stage_exact = 1.0 if next_stage_norm and stage_norm == next_stage_norm else 0.0

        combined[idx] = (
            base_score
            + (OVERLAP_BOOST * lexical)
            + (STAGE_BOOST * stage_overlap)
            + (EXACT_STAGE_BOOST * stage_exact)
            + (NEXT_STAGE_BOOST * next_stage_exact)
        )

    ranked = sorted(combined.items(), key=lambda x: x[1], reverse=True)
    results = []
    for idx, score in ranked:
        if score < SCORE_THRESHOLD:
            continue
        results.append((idx, score))
        if len(results) >= TOP_K:
            break
    if not results:
        results = ranked[:TOP_K]
    return results


def call_ollama(prompt: str, model_name: str) -> str:
    payload = {
        "model": model_name,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0.15,
            "top_p": 0.9,
            "num_ctx": 4096,
            "num_predict": 512,
        },
    }
    resp = requests.post(OLLAMA_URL, json=payload, timeout=120)
    resp.raise_for_status()
    return resp.json().get("response", "")


def parse_args():
    parser = argparse.ArgumentParser(description="Run Hajj assistant.")
    parser.add_argument("-q", "--question", help="Question to answer")
    parser.add_argument("--model", help="Single Ollama model name")
    parser.add_argument("--models", help="Comma-separated list of Ollama models")
    parser.add_argument("--no-fallback", action="store_true", help="Disable extractive fallback")
    return parser.parse_args()


def resolve_models(args) -> list:
    if args.model:
        return [args.model]
    if args.models:
        return [m.strip() for m in args.models.split(",") if m.strip()]
    if OLLAMA_MODEL.strip():
        return [m.strip() for m in OLLAMA_MODEL.split(",") if m.strip()]
    return [OLLAMA_MODEL]


def main():
    if not INDEX_PATH.exists():
        raise FileNotFoundError(f"Index not found: {INDEX_PATH}")
    if not CHUNKS_PATH.exists():
        raise FileNotFoundError(f"Chunks file not found: {CHUNKS_PATH}")

    args = parse_args()

    chunks = load_chunks()
    index = faiss.read_index(str(INDEX_PATH))
    try:
        model = SentenceTransformer(
            EMBEDDING_MODEL_PATH,
            cache_folder=HF_CACHE_DIR or None,
            local_files_only=HF_LOCAL_ONLY,
        )
    except Exception as exc:
        raise RuntimeError("Embedding model not found. Set EMBEDDING_MODEL_PATH.") from exc

    query = (args.question or "").strip()
    if not query:
        query = input("اكتب سؤالك بالعربية: ").strip()
    if not query:
        print("لا يوجد سؤال.")
        return

    if is_off_topic(query):
        print(OFF_TOPIC_MSG)
        return

    faraiz_only  = is_faraiz_only_question(query)
    is_journey_q = is_start_of_hajj_question(query)

    # لأسئلة "خطوات الحج" الكاملة: نرجع الملخص الثابت مباشرة بدون LLM
    # المودل الصغير لا يحافظ على الترتيب الزمني حتى مع السياق الصحيح
    if is_journey_q and not faraiz_only:
        print("\nالاجابة:")
        print(HAJJ_JOURNEY_SUMMARY)
        print("\n💡 هل تبي أشرح لك تفاصيل أي خطوة؟")
        OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT_PATH.write_text(HAJJ_JOURNEY_SUMMARY, encoding="utf-8")
        return

    if is_journey_q:  # faraiz_only فقط
        hits = get_hajj_overview_chunks(chunks, faraiz_only=True)
    else:
        hits = hybrid_retrieve(chunks, index, query, model=model)
    if not hits:
        print("لم يتم العثور على سياق مناسب.")
        return

    contexts = [chunk_text_display(chunks[idx]) for idx, _ in hits]
    context_block = CONTEXT_SEPARATOR.join(contexts)

    top_meta     = chunks[hits[0][0]].get("metadata", {}) if hits else {}
    phase        = top_meta.get("phase_title", "")
    content_type = top_meta.get("content_type", top_meta.get("type", ""))

    prompt = (
        SYSTEM_PROMPT.format(phase=phase, content_type=content_type)
        + "\n\n"
        + USER_PROMPT.format(context=context_block, question=query)
    )

    models = resolve_models(args)
    use_fallback = USE_FALLBACK and not args.no_fallback
    answers = []

    for model_name in models:
        answer = call_ollama(prompt, model_name).strip()
        used_fallback = False
        if use_fallback and (looks_like_refusal(answer) or not is_grounded(answer, context_block)):
            answer = extractive_answer(query, contexts)
            used_fallback = True
        if use_fallback and needs_detailed_answer(query) and len(content_tokens(answer)) < 10:
            answer = extractive_answer(query, contexts)
            used_fallback = True
        if use_fallback and (looks_like_refusal(answer) or collapse_ws(answer) in {"", "لا اعرف"}):
            answer = CLARIFY_MSG
            used_fallback = True
        answer = ensure_followup(answer)
        answers.append((model_name, answer, used_fallback))

    if len(answers) == 1:
        output_text = f"السؤال: {query}\n\nالاجابة:\n{answers[0][1]}\n"
        print("\nالاجابة:")
        print(answers[0][1])
    else:
        lines = [f"السؤال: {query}", ""]
        for model_name, answer, used_fallback in answers:
            suffix = " (fallback)" if used_fallback else ""
            lines.append(f"== {model_name}{suffix} ==")
            lines.append(answer)
            lines.append("")
        output_text = "\n".join(lines).rstrip() + "\n"
        print("\n" + output_text)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(output_text, encoding="utf-8")


if __name__ == "__main__":
    main()