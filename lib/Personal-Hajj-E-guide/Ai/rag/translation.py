"""
translation.py — language detection and glossary protection for multilingual
queries (Arabic / English / Urdu).

Stage 1 of the multilingual pipeline. Sits between the API edge and the
existing Arabic RAG core (knowledge.py, retrieval.py, pipeline.py).
Translation backends (NLLB via CTranslate2) and TTS (Piper) are added in
later stages — this module deliberately has no model dependencies so the
glossary and language-detection logic can be tested in isolation.

Public surface:
    AR, EN, UR, LANGUAGES               language constants
    detect_language(text)               rule-based AR/EN/UR classifier
    GLOSSARY_TERMS                      trilingual canonical Hajj terms
    protect_terms(text, lang)           swap canonical terms for opaque placeholders
    restore_terms(text, lang, m)        put canonical terms back, in any target lang
    translate(text, src, tgt)           NLLB MT (lazy-loaded on first call)
    translate_with_glossary(t, s, t)    end-to-end protect → translate → restore
    unload_nllb()                       free MT model (Track B / on-device use)
"""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from pathlib import Path


# ── Language constants ────────────────────────────────────────────────────
AR = "ar"
EN = "en"
UR = "ur"
LANGUAGES: tuple[str, ...] = (AR, EN, UR)


# ── Language detection ────────────────────────────────────────────────────
_LATIN_RE  = re.compile(r"[A-Za-z]")
_ARABIC_RE = re.compile(r"[؀-ۿ]")

# Letters that exist in Urdu (and Persian) but not in standard Arabic.
_URDU_ONLY_CHARS = set("ٹڈڑںہےۂۃۓپچگژڭۀ")

# High-frequency Urdu function words that don't occur in Arabic prose.
# Padded with spaces on both sides to avoid substring false positives.
_URDU_MARKERS = (
    " ہے ", " ہیں ", " کے ", " کا ", " کی ", " کو ",
    " میں ", " اور ", " آپ ", " پر ", " سے ", " یہ ",
    " وہ ", " کیا ", " ہم ", " تم ", " بھی ",
)


def detect_language(text: str) -> str:
    """Return AR, EN, or UR. Defaults to AR when input is empty/ambiguous."""
    if not text or not text.strip():
        return AR

    latin  = len(_LATIN_RE.findall(text))
    arabic = len(_ARABIC_RE.findall(text))

    if latin > arabic:
        return EN
    if arabic == 0:
        return EN if latin else AR

    if any(c in _URDU_ONLY_CHARS for c in text):
        return UR
    padded = f" {text} "
    if any(m in padded for m in _URDU_MARKERS):
        return UR
    return AR


# ── Glossary terms (trilingual) ───────────────────────────────────────────
# Stable id → canonical forms in each language plus alias lists.
# Canonical forms are diacritic-free; diacritic/alternate spellings live in
# the *_aliases lists.
#
# NOTE: Urdu forms follow common scholarly transliteration but should be
# reviewed with a native speaker before production. Add new terms here; do
# not edit the existing Arabic-only GLOSSARY in knowledge.py for that.

GLOSSARY_TERMS: dict[str, dict] = {
    "ihram": {
        "ar": "الإحرام", "en": "Ihram", "ur": "احرام",
        "ar_aliases": ["احرام", "محرم", "ملابس الاحرام"],
        "en_aliases": ["ihraam", "ihrām", "ehram"],
        "ur_aliases": ["اِحرام"],
    },
    "talbiyah": {
        "ar": "التلبية", "en": "Talbiyah", "ur": "تلبیہ",
        "ar_aliases": ["تلبيه", "لبيك"],
        "en_aliases": ["talbiyya"],
        "ur_aliases": [],
    },
    "miqat": {
        "ar": "الميقات", "en": "Miqat", "ur": "میقات",
        "ar_aliases": ["ميقات", "مواقيت"],
        "en_aliases": ["mīqāt", "miqaat", "meeqaat"],
        "ur_aliases": [],
    },
    "tawaf": {
        "ar": "الطواف", "en": "Tawaf", "ur": "طواف",
        "ar_aliases": ["طواف", "اطوف"],
        "en_aliases": ["tawāf", "tawaaf"],
        "ur_aliases": [],
    },
    "sai": {
        "ar": "السعي", "en": "Sai", "ur": "سعی",
        "ar_aliases": ["سعي", "السعى"],
        "en_aliases": ["sa'i", "saee", "saʿy"],
        "ur_aliases": ["سعئ"],
    },
    "arafah": {
        "ar": "عرفة", "en": "Arafah", "ur": "عرفہ",
        "ar_aliases": ["عرفه", "عرفات", "الوقوف بعرفه"],
        "en_aliases": ["arafat", "ʿarafah", "arafa"],
        "ur_aliases": ["عرفات"],
    },
    "muzdalifah": {
        "ar": "مزدلفة", "en": "Muzdalifah", "ur": "مزدلفہ",
        "ar_aliases": ["مزدلفه"],
        "en_aliases": ["muzdalifa"],
        "ur_aliases": [],
    },
    "mina": {
        "ar": "منى", "en": "Mina", "ur": "منیٰ",
        "ar_aliases": ["مني"],
        "en_aliases": ["minā"],
        "ur_aliases": ["منی"],
    },
    "jamarat": {
        "ar": "الجمرات", "en": "Jamarat", "ur": "جمرات",
        "ar_aliases": ["جمرات", "جمره", "الجمره", "جمرة العقبه"],
        "en_aliases": ["jamaraat", "jamrah", "jamarah"],
        "ur_aliases": [],
    },
    "halq": {
        "ar": "الحلق", "en": "Halq", "ur": "حلق",
        "ar_aliases": ["حلق", "تقصير"],
        "en_aliases": ["taqsir", "haircutting"],
        "ur_aliases": [],
    },
    "tawaf_al_ifadah": {
        "ar": "طواف الإفاضة", "en": "Tawaf al-Ifadah", "ur": "طوافِ افاضہ",
        "ar_aliases": ["طواف الافاضه", "طواف الزياره", "طواف الزيارة"],
        "en_aliases": ["tawaf al-ifaadah", "tawaf al-ziyarah", "tawaf az-ziyarah"],
        "ur_aliases": ["طواف افاضہ", "طواف زیارت"],
    },
    "tawaf_al_wadaa": {
        "ar": "طواف الوداع", "en": "Tawaf al-Wadaa", "ur": "طوافِ وداع",
        "ar_aliases": ["الوداع"],
        "en_aliases": ["farewell tawaf", "tawaf al-wada"],
        "ur_aliases": ["طواف وداع"],
    },
    "hady": {
        "ar": "الهدي", "en": "Hady", "ur": "ہدی",
        "ar_aliases": ["هدي", "ذبح", "اضحيه", "نحر الهدي"],
        "en_aliases": ["hadiy", "qurbani", "sacrifice"],
        "ur_aliases": ["قربانی"],
    },
    "ifadah": {
        "ar": "الإفاضة", "en": "Ifadah", "ur": "افاضہ",
        "ar_aliases": ["الافاضه", "يفيضون"],
        "en_aliases": ["ifaadah", "ifaada"],
        "ur_aliases": [],
    },
    "tarwiyah": {
        "ar": "التروية", "en": "Tarwiyah", "ur": "ترویہ",
        "ar_aliases": ["يوم التروية", "الثامن"],
        "en_aliases": ["day of tarwiyah", "tarwiya"],
        "ur_aliases": ["یومِ ترویہ"],
    },
    "nahr": {
        "ar": "النحر", "en": "Nahr", "ur": "نحر",
        "ar_aliases": ["يوم النحر", "العاشر"],
        "en_aliases": ["day of sacrifice", "day of nahr"],
        "ur_aliases": ["یومِ نحر"],
    },
    "tashriq": {
        "ar": "أيام التشريق", "en": "Days of Tashriq", "ur": "ایامِ تشریق",
        "ar_aliases": ["التشريق", "ايام التشريق"],
        "en_aliases": ["ayyam al-tashriq", "tashreeq"],
        "ur_aliases": ["ایام تشریق"],
    },
}


# ── Term protection (placeholder swap around MT) ──────────────────────────
# ASCII-only sentinels chosen to be opaque to NLLB's BPE tokenizer:
# no underscores (which split into subwords), no non-ASCII, and an unlikely
# n-gram so MT models keep them as a single unit.

_PLACEHOLDER_FMT = "ZHJT{:02d}Z"
_PLACEHOLDER_RE  = re.compile(r"ZHJT(\d{2})Z")


@dataclass
class TermMapping:
    """Records which placeholder maps to which term id, in insertion order."""
    placeholder_to_term: dict[str, str] = field(default_factory=dict)


# ── Arabic clitic + diacritic handling ────────────────────────────────────
# Arabic attaches several single-letter particles directly to the start of
# the next word: و (and), ف (so), ب (with), ك (like), ل (for/to). The lām
# particle triggers alif-elision when applied to a definite-article word:
# لـ + الطواف → للطواف (the alif of ال is dropped).
#
# We expand each AR alias to cover these forms so a phrase like "بالطواف"
# is matched as a unit and replaced with the same placeholder as the bare
# "الطواف" — losing the preposition is acceptable because NLLB will
# reconstruct it from English context.

_AR_PREFIXES_DEF   = ("و", "ف", "ب", "ك")    # alif-of-ال preserved
_AR_PREFIXES_INDEF = ("و", "ف", "ب", "ك", "ل")

# Arabic diacritic / Tashkeel range plus dagger alif (ٰ).
_AR_DIACRITIC_RE = r"[ً-ٰٟ]*"


def _ar_alias_variants(alias: str) -> list[str]:
    """Return `alias` plus common clitic-prefixed forms (definite-aware)."""
    if not alias:
        return [alias]
    variants = [alias]
    if alias.startswith("ال") and len(alias) > 2:
        rest = alias[2:]
        for p in _AR_PREFIXES_DEF:
            variants.append(f"{p}{alias}")     # والطواف فالطواف بالطواف كالطواف
        variants.append(f"لل{rest}")           # لـ + ال → لل (alif elided)
    else:
        for p in _AR_PREFIXES_INDEF:
            variants.append(f"{p}{alias}")
    return variants


def _ar_to_tolerant_pattern(alias: str) -> str:
    """Build a regex string that matches `alias` with optional diacritics between letters."""
    return _AR_DIACRITIC_RE.join(re.escape(c) for c in alias)


def _aliases_for(term_id: str, lang: str) -> list[str]:
    """Return canonical + alias forms for a term in `lang`, longest-first.
    For AR, also expands each alias with clitic-prefix variants."""
    entry = GLOSSARY_TERMS[term_id]
    base: set[str] = {entry[lang], *entry.get(f"{lang}_aliases", [])}
    if lang == AR:
        expanded: set[str] = set()
        for a in base:
            expanded.update(_ar_alias_variants(a))
        base = expanded
    return sorted((a for a in base if a), key=len, reverse=True)


def _build_term_pattern(aliases: list[str], lang: str, flags: int) -> re.Pattern:
    """Compile a single alternation regex matching any alias for one term.

    For AR, allows optional diacritics between letters (so `الطّواف` matches
    the bare `الطواف`). Aliases must be in longest-first order so the regex
    engine prefers longer matches at each position (matters for clitic forms
    like `بالطواف` vs the substring `الطواف`).
    """
    if lang == AR:
        parts = [_ar_to_tolerant_pattern(a) for a in aliases]
    else:
        parts = [re.escape(a) for a in aliases]
    return re.compile("|".join(parts), flags)


def protect_terms(text: str, lang: str) -> tuple[str, TermMapping]:
    """
    Replace canonical religious terms in `text` (assumed to be in `lang`)
    with opaque placeholders. The returned TermMapping is what `restore_terms`
    needs to put the canonical form back — possibly in a different language.
    """
    if lang not in LANGUAGES:
        raise ValueError(f"Unsupported language: {lang}")

    flags = re.IGNORECASE if lang == EN else 0
    mapping = TermMapping()

    for term_id in GLOSSARY_TERMS:
        aliases = _aliases_for(term_id, lang)
        if not aliases:
            continue
        pattern = _build_term_pattern(aliases, lang, flags)
        if pattern.search(text):
            placeholder = _PLACEHOLDER_FMT.format(len(mapping.placeholder_to_term))
            text = pattern.sub(placeholder, text)
            mapping.placeholder_to_term[placeholder] = term_id

    return text, mapping


def restore_terms(text: str, lang: str, mapping: TermMapping) -> str:
    """Swap placeholders back to the canonical form in `lang`."""
    if lang not in LANGUAGES:
        raise ValueError(f"Unsupported language: {lang}")

    def _replace(match: re.Match) -> str:
        placeholder = match.group(0)
        term_id = mapping.placeholder_to_term.get(placeholder)
        if term_id is None:
            return placeholder
        return GLOSSARY_TERMS[term_id][lang]

    return _PLACEHOLDER_RE.sub(_replace, text)


# ── NLLB translation (lazy-loaded) ────────────────────────────────────────
# NLLB-200 language tags (Flores-200 codes). See:
# https://github.com/facebookresearch/flores/blob/main/flores200/README.md
_NLLB_LANG_CODES: dict[str, str] = {
    AR: "arb_Arab",   # Modern Standard Arabic
    EN: "eng_Latn",
    UR: "urd_Arab",
}

_DEFAULT_MODEL_DIR = Path(__file__).resolve().parents[1] / "models" / "nllb-200-distilled-600M-int8"
NLLB_MODEL_DIR = Path(os.getenv("NLLB_MODEL_DIR", str(_DEFAULT_MODEL_DIR)))
NLLB_DEVICE    = os.getenv("NLLB_DEVICE", "cpu")           # "cuda" if available
NLLB_BEAM_SIZE = int(os.getenv("NLLB_BEAM_SIZE", "4"))

_translator = None  # ctranslate2.Translator
_tokenizer  = None  # sentencepiece.SentencePieceProcessor


def _load_nllb() -> None:
    """Load NLLB into memory. Raises a clear error if deps or files are missing."""
    global _translator, _tokenizer
    if _translator is not None:
        return

    try:
        import ctranslate2
        import sentencepiece as spm
    except ImportError as exc:
        raise RuntimeError(
            "Translation requires ctranslate2 and sentencepiece. "
            "Install with: pip install -r Ai/requirements.txt"
        ) from exc

    if not NLLB_MODEL_DIR.exists():
        raise RuntimeError(
            f"NLLB model not found at {NLLB_MODEL_DIR}. "
            "Run: python Ai/setup_translation.py"
        )

    spm_path = NLLB_MODEL_DIR / "sentencepiece.bpe.model"
    if not spm_path.exists():
        raise RuntimeError(f"SentencePiece model missing: {spm_path}")

    _translator = ctranslate2.Translator(str(NLLB_MODEL_DIR), device=NLLB_DEVICE)
    sp = spm.SentencePieceProcessor()
    sp.load(str(spm_path))
    _tokenizer = sp


def unload_nllb() -> None:
    """Free MT resources. Useful on memory-constrained devices (Track B)."""
    global _translator, _tokenizer
    _translator = None
    _tokenizer  = None


def translate(text: str, src: str, tgt: str) -> str:
    """
    Translate `text` from `src` language to `tgt` (both AR/EN/UR).
    Pass-through when src == tgt or text is empty.
    """
    if src not in LANGUAGES or tgt not in LANGUAGES:
        raise ValueError(f"Unsupported language pair: {src}->{tgt}")
    if src == tgt or not text or not text.strip():
        return text

    _load_nllb()
    assert _translator is not None and _tokenizer is not None  # for type-checkers

    src_tag = _NLLB_LANG_CODES[src]
    tgt_tag = _NLLB_LANG_CODES[tgt]

    # NLLB encoder format: [<src_lang_tag>, ...bpe_tokens..., </s>]
    # The lang tags are special vocab entries that CT2 looks up by string.
    source_tokens = [src_tag] + _tokenizer.encode(text, out_type=str) + ["</s>"]

    results = _translator.translate_batch(
        [source_tokens],
        target_prefix=[[tgt_tag]],
        beam_size=NLLB_BEAM_SIZE,
        max_decoding_length=512,
    )

    output_tokens = results[0].hypotheses[0]
    if output_tokens and output_tokens[0] == tgt_tag:
        output_tokens = output_tokens[1:]

    return _tokenizer.decode(output_tokens)


def translate_with_glossary(text: str, src: str, tgt: str) -> str:
    """
    End-to-end pipeline: protect canonical terms, run MT, restore terms in
    target language. Use this from api.py rather than calling `translate`
    directly — it's what guarantees Hajj terminology survives MT intact.
    """
    if src == tgt:
        return text
    protected, mapping = protect_terms(text, src)
    mt_output = translate(protected, src, tgt)
    return restore_terms(mt_output, tgt, mapping)


# ── Canned localized messages ─────────────────────────────────────────────
# Hand-written translations for fixed responses. Avoid round-tripping these
# through NLLB on every off-topic / clarify response — both saves latency
# and keeps tone consistent.

import random as _random

# Multiple phrasings per (key, lang) so the assistant doesn't sound robotic.
# AR variants are sourced from knowledge.py (single source of truth so the
# CLI / eval / API stay consistent). EN and UR have parallel variants with
# the "trusted sheikh / fatwa authority" specifics stripped so we don't
# nominate one institution.

# Lazy-imported to avoid a circular import at module load time.
def _ar_variants(key: str) -> list[str]:
    import sys as _sys
    knowledge = _sys.modules.get("knowledge") or _sys.modules.get("Ai.rag.knowledge")
    if knowledge is None:
        # Fall back to a single-element default if knowledge isn't loaded yet.
        from knowledge import (
            CLARIFY_VARIANTS, OFF_TOPIC_VARIANTS, FATWA_VARIANTS,
        )
        knowledge_vars = {
            "clarify":   CLARIFY_VARIANTS,
            "off_topic": OFF_TOPIC_VARIANTS,
            "fatwa":     FATWA_VARIANTS,
        }
        return knowledge_vars.get(key, [])
    return {
        "clarify":   getattr(knowledge, "CLARIFY_VARIANTS",   []),
        "off_topic": getattr(knowledge, "OFF_TOPIC_VARIANTS", []),
        "fatwa":     getattr(knowledge, "FATWA_VARIANTS",     []),
    }.get(key, [])


LOCALIZED_MESSAGES: dict[str, dict[str, list[str]]] = {
    "clarify": {
        EN: [
            "I didn't quite understand. Could you rephrase your question?",
            "I'm not sure I caught that — could you say it differently?",
            "Could you clarify your question a bit more?",
        ],
        UR: [
            "میں آپ کا سوال سمجھ نہیں سکا۔ کیا آپ دوبارہ بیان کر سکتے ہیں؟",
            "مجھے آپ کا مطلب پوری طرح سمجھ نہیں آیا، براہِ کرم دوبارہ پوچھیں۔",
            "اپنا سوال تھوڑا اور واضح کر دیں؟",
        ],
    },
    "off_topic": {
        EN: [
            "I don't have that information in my Hajj guide. The guide only covers Hajj rites and their related rulings.",
            "That's outside the scope of my Hajj guide. I can help with the steps and rulings of Hajj.",
            "Sorry — that isn't part of the Hajj material I have. I focus on the rites of Hajj and their rulings.",
        ],
        UR: [
            "یہ معلومات میرے حج رہنما میں موجود نہیں۔ یہ رہنما صرف حج کے ارکان اور متعلقہ احکام کا احاطہ کرتا ہے۔",
            "یہ سوال میرے حج کے دائرے سے باہر ہے۔ میں حج کے مراحل اور احکام میں مدد کر سکتا ہوں۔",
            "معذرت، یہ بات میرے حج کے مواد میں شامل نہیں۔ میں حج کے ارکان اور احکام پر توجہ دیتا ہوں۔",
        ],
    },
    "fatwa": {
        EN: [
            "This question needs a fatwa from a qualified scholar. I'm here to help with the practical steps of Hajj and its general rulings.",
            "For this one it's better to ask a qualified scholar. I can guide you through the stages of Hajj and its general rulings.",
            "This belongs to a scholar's domain. I focus on the steps of Hajj and its general rulings.",
        ],
        UR: [
            "اس سوال کے لیے کسی مستند عالم سے فتویٰ لینا بہتر ہے۔ میں حج کے عملی مراحل اور عمومی احکام میں مدد کے لیے حاضر ہوں۔",
            "یہ سوال علماء کے دائرے میں آتا ہے۔ میں حج کے مراحل اور عمومی احکام کی رہنمائی کر سکتا ہوں۔",
            "اس کا جواب کسی مستند عالم سے لینا مناسب ہے۔ میں حج کے مراحل اور عمومی احکام میں متخصص ہوں۔",
        ],
    },
    "translation_unavailable": {
        EN: ["Translation service is not available right now."],
        UR: ["ترجمہ کی سروس فی الحال دستیاب نہیں ہے۔"],
    },
}


def localize(key: str, lang: str) -> str:
    """Return one phrasing for `key` in `lang`. Picks randomly when there are
    multiple variants. Falls back to AR if `lang`-specific variants are missing
    and to "" if the key is unknown entirely."""
    if lang == AR:
        variants = _ar_variants(key)
    else:
        variants = LOCALIZED_MESSAGES.get(key, {}).get(lang, [])
        if not variants:
            variants = _ar_variants(key)
    return _random.choice(variants) if variants else ""
