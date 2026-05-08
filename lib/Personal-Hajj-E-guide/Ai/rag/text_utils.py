"""
text_utils.py — أدوات معالجة النص العربي
لا تعتمد على أي ملف آخر في المشروع.
"""

import re


# ── تطبيع النص العربي ──────────────────────────────────────────────────────
def normalize_arabic(text: str) -> str:
    text = re.sub(r"[إأآا]", "ا", text)
    text = re.sub(r"ى", "ي", text)
    text = re.sub(r"ؤ", "و", text)
    text = re.sub(r"ئ", "ي", text)
    text = re.sub(r"ة", "ه", text)
    text = re.sub(r"ـ", "", text)
    text = re.sub(r"[ًٌٍَُِّْ]", "", text)
    return text


def collapse_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def tokenize_arabic(text: str) -> list[str]:
    text = normalize_arabic(text)
    text = re.sub(r"[؟!،؛\.\"«»\(\)\[\]']", " ", text)
    text = re.sub(r"[^\u0600-\u06FF0-9A-Za-z\s]", " ", text)
    return [t for t in text.split() if t]


AR_STOPWORDS: set[str] = {
    "في", "من", "على", "الى", "الي", "عن", "ما", "هو", "هي", "هذا", "هذه",
    "ذلك", "تلك", "ثم", "او", "و", "الذي", "التي", "ان", "لا", "لم", "لن",
    "قد", "بعد", "قبل", "مع", "بين", "كل", "كان", "كانت", "يكون", "تكون",
    "اذا", "عند", "حتى", "كما", "اي", "تم", "فان",
}


def content_tokens(text: str) -> list[str]:
    tokens = tokenize_arabic(text)
    return [t for t in tokens if len(t) > 1 and t not in AR_STOPWORDS]


def content_tokens_from_tokens(tokens: list[str]) -> list[str]:
    return [t for t in tokens if len(t) > 1 and t not in AR_STOPWORDS]


def overlap_score(query_tokens: list[str], doc_tokens: list[str]) -> float:
    if not query_tokens or not doc_tokens:
        return 0.0
    doc_set = set(doc_tokens)
    overlap = sum(1 for t in query_tokens if t in doc_set)
    return overlap / max(len(query_tokens), 1)


# ── معالجة الجمل ───────────────────────────────────────────────────────────
def split_sentences(text: str) -> list[str]:
    parts = re.split(r"(?<=[\.!?؟])\s+", text)
    return [p.strip() for p in parts if p.strip()]


def strip_headings(text: str) -> str:
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    cleaned = []
    for ln in lines:
        if ln.startswith("PHASE ") or ln.startswith("STAGE:") or ln.startswith("TYPE:"):
            continue
        ln = re.sub(r"^STEP\s+\d+\s*\([^)]*\)\s*:?\s*", "", ln).strip()
        if not ln:
            continue
        cleaned.append(ln)
    return " ".join(cleaned).strip()


def dedupe_sentences(sentences: list[str]) -> list[str]:
    seen: set[str] = set()
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
