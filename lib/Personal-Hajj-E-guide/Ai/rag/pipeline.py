"""
pipeline.py — المنسق الرئيسي: LLM + fallback + main()
يعتمد على: text_utils, knowledge, location, retrieval
"""

import argparse
import os
import sys as _sys
from pathlib import Path

_RAG_DIR = Path(__file__).resolve().parent
if str(_RAG_DIR) not in _sys.path:
    _sys.path.insert(0, str(_RAG_DIR))

import faiss
import requests
from sentence_transformers import SentenceTransformer

from text_utils import content_tokens, collapse_ws  # noqa: E402
from knowledge import (  # noqa: E402
    CLARIFY_MSG, OFF_TOPIC_MSG, FATWA_MSG, SYSTEM_PROMPT, USER_PROMPT,
    CONTEXT_SEPARATOR, HAJJ_JOURNEY_SUMMARY,
    GLOSSARY, REFUSAL_MARKERS,
    get_glossary_for_query, looks_like_refusal, ensure_followup,
    get_clarify_msg, get_off_topic_msg, get_fatwa_msg,
    is_off_topic, is_fatwa_question, is_faraiz_only_question, is_start_of_hajj_question,
    needs_detailed_answer,
)
from location import detect_zone_from_gps  # noqa: E402
from retrieval import (  # noqa: E402
    INDEX_PATH, CHUNKS_PATH, EMBEDDING_MODEL_PATH, HF_LOCAL_ONLY, HF_CACHE_DIR,
    load_chunks, chunk_text_display,
    hybrid_retrieve, get_hajj_overview_chunks,
    is_grounded, has_inversion, has_latin_codeswitch, has_missing_list_items,
    extractive_answer,
)
import translation as _tr  # noqa: E402  (underscore → not re-exported by ollama_pipeline shim)


# ── LLM (Ollama — للتطوير والتقييم فقط) ────────────────────────────────────
OLLAMA_URL   = "http://localhost:11434/api/generate"
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "silma-kashif:2b")
USE_FALLBACK = os.getenv("USE_FALLBACK", "1") == "1"
OUTPUT_PATH  = Path(__file__).resolve().parents[1] / "tests" / "data" / "last_answer.txt"


def call_ollama(prompt: str, model_name: str) -> str:
    payload = {
        "model":  model_name,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0.15,
            "top_p":       0.9,
            "num_ctx":     4096,
            "num_predict": 512,
        },
    }
    resp = requests.post(OLLAMA_URL, json=payload, timeout=120)
    resp.raise_for_status()
    return resp.json().get("response", "")


# ── End-to-end answer (used by api.py, voice loop, eval scripts) ──────────
def answer_question(
    question: str,
    *,
    chunks,
    index,
    emb_model,
    lang: str | None = None,
    lat: float | None = None,
    lng: float | None = None,
    ollama_model: str | None = None,
    use_fallback: bool | None = None,
) -> dict:
    """Run the full multilingual RAG flow for one question.

    Mirrors the /ask handler in api.py — translate query → off-topic / fatwa
    gates → retrieve → generate → fallback → translate answer back. Returns
    a dict so the caller (FastAPI handler, voice loop, CLI) can decide how
    to render it.
    """
    query_orig = (question or "").strip()
    if not query_orig:
        raise ValueError("Empty question.")

    user_lang = lang if lang in _tr.LANGUAGES else _tr.detect_language(query_orig)

    # ── translate query → AR (the RAG core is AR-only) ────────────────
    if user_lang == _tr.AR:
        query_ar = query_orig
    else:
        query_ar = _tr.translate_with_glossary(query_orig, user_lang, _tr.AR)

    # ── fatwa gate ─────────────────────────────────────────────────────
    if is_fatwa_question(query_ar):
        return {
            "answer":        _tr.localize("fatwa", user_lang),
            "lang":          user_lang,
            "phase":         "",
            "zone":          "",
            "off_topic":     False,
            "fatwa":         True,
            "used_fallback": False,
        }

    # ── off-topic gate ─────────────────────────────────────────────────
    if is_off_topic(query_ar):
        return {
            "answer":        _tr.localize("off_topic", user_lang),
            "lang":          user_lang,
            "phase":         "",
            "zone":          "",
            "off_topic":     True,
            "fatwa":         False,
            "used_fallback": False,
        }

    # ── GPS → zone (optional retrieval boost) ─────────────────────────
    user_zone = ""
    if lat is not None and lng is not None:
        user_zone = detect_zone_from_gps(lat, lng)

    # ── retrieve ──────────────────────────────────────────────────────
    faraiz_only  = is_faraiz_only_question(query_ar)
    is_journey_q = is_start_of_hajj_question(query_ar)

    if is_journey_q:
        hits = get_hajj_overview_chunks(chunks, faraiz_only=faraiz_only)
    else:
        hits = hybrid_retrieve(chunks, index, query_ar, model=emb_model, user_zone=user_zone)

    if not hits:
        return {
            "answer":        _tr.localize("clarify", user_lang),
            "lang":          user_lang,
            "phase":         "",
            "zone":          user_zone,
            "off_topic":     False,
            "fatwa":         False,
            "used_fallback": True,
        }

    contexts = [chunk_text_display(chunks[idx]) for idx, _ in hits]
    if is_journey_q and not faraiz_only:
        contexts = [HAJJ_JOURNEY_SUMMARY] + contexts
    glossary_block = get_glossary_for_query(query_ar)
    context_parts  = ([glossary_block] if glossary_block else []) + contexts
    context_block  = CONTEXT_SEPARATOR.join(context_parts)

    top_meta     = chunks[hits[0][0]].get("metadata", {})
    phase        = top_meta.get("phase_title", "")
    content_type = top_meta.get("content_type", top_meta.get("type", ""))

    prompt = (
        SYSTEM_PROMPT.format(phase=phase, content_type=content_type)
        + "\n\n"
        + USER_PROMPT.format(context=context_block, question=query_ar)
    )

    model_name    = ollama_model or OLLAMA_MODEL
    use_fb        = USE_FALLBACK if use_fallback is None else use_fallback
    used_fallback = False

    try:
        answer = call_ollama(prompt, model_name).strip()
    except Exception:
        answer = ""

    answer_was_clarify = False
    top_chunk = contexts[0] if contexts else ""
    if use_fb:
        if (
            looks_like_refusal(answer)
            or not is_grounded(answer, context_block)
            or has_inversion(answer, context_block)
            or has_latin_codeswitch(answer)
            or (top_chunk and has_missing_list_items(answer, top_chunk))
        ):
            answer = extractive_answer(query_ar, contexts)
            used_fallback = True
        if needs_detailed_answer(query_ar) and len(content_tokens(answer)) < 10:
            answer = extractive_answer(query_ar, contexts)
            used_fallback = True
        if looks_like_refusal(answer) or collapse_ws(answer) in {"", "لا اعرف"}:
            answer = get_clarify_msg()
            answer_was_clarify = True
            used_fallback = True

    answer = ensure_followup(answer)

    # ── translate answer back to user's language ──────────────────────
    if user_lang != _tr.AR:
        if answer_was_clarify:
            answer = _tr.localize("clarify", user_lang)
        else:
            try:
                answer = _tr.translate_with_glossary(answer, _tr.AR, user_lang)
            except RuntimeError:
                pass  # keep AR rather than fail outright

    return {
        "answer":        answer,
        "lang":          user_lang,
        "phase":         phase,
        "zone":          user_zone,
        "off_topic":     False,
        "fatwa":         False,
        "used_fallback": used_fallback,
    }


# ── CLI ────────────────────────────────────────────────────────────────────
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Hajj assistant.")
    parser.add_argument("-q", "--question", help="Question to answer")
    parser.add_argument("--model",    help="Single Ollama model name")
    parser.add_argument("--models",   help="Comma-separated list of Ollama models")
    parser.add_argument("--no-fallback", action="store_true", help="Disable extractive fallback")
    return parser.parse_args()


def resolve_models(args: argparse.Namespace) -> list[str]:
    if args.model:
        return [args.model]
    if args.models:
        return [m.strip() for m in args.models.split(",") if m.strip()]
    return [m.strip() for m in OLLAMA_MODEL.split(",") if m.strip()] or [OLLAMA_MODEL]


def main() -> None:
    if not INDEX_PATH.exists():
        raise FileNotFoundError(f"Index not found: {INDEX_PATH}")
    if not CHUNKS_PATH.exists():
        raise FileNotFoundError(f"Chunks file not found: {CHUNKS_PATH}")

    args   = parse_args()
    chunks = load_chunks()
    index  = faiss.read_index(str(INDEX_PATH))

    try:
        model = SentenceTransformer(
            EMBEDDING_MODEL_PATH,
            cache_folder=HF_CACHE_DIR or None,
            local_files_only=HF_LOCAL_ONLY,
        )
    except Exception as exc:
        raise RuntimeError("Embedding model not found. Set EMBEDDING_MODEL_PATH.") from exc

    query = (args.question or "").strip() or input("اكتب سؤالك بالعربية: ").strip()
    if not query:
        print("لا يوجد سؤال.")
        return

    if is_fatwa_question(query):
        print(FATWA_MSG)
        return

    if is_off_topic(query):
        print(OFF_TOPIC_MSG)
        return

    faraiz_only  = is_faraiz_only_question(query)
    is_journey_q = is_start_of_hajj_question(query)

    if is_journey_q and not faraiz_only:
        print("\nالاجابة:")
        print(HAJJ_JOURNEY_SUMMARY)
        print("\n💡 هل تبي أشرح لك تفاصيل أي خطوة؟")
        OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT_PATH.write_text(HAJJ_JOURNEY_SUMMARY, encoding="utf-8")
        return

    hits = get_hajj_overview_chunks(chunks, faraiz_only=True) if is_journey_q \
        else hybrid_retrieve(chunks, index, query, model=model)

    if not hits:
        print("لم يتم العثور على سياق مناسب.")
        return

    contexts       = [chunk_text_display(chunks[idx]) for idx, _ in hits]
    glossary_block = get_glossary_for_query(query)
    context_parts  = ([glossary_block] if glossary_block else []) + contexts
    context_block  = CONTEXT_SEPARATOR.join(context_parts)

    top_meta     = chunks[hits[0][0]].get("metadata", {})
    phase        = top_meta.get("phase_title", "")
    content_type = top_meta.get("content_type", top_meta.get("type", ""))

    prompt = (
        SYSTEM_PROMPT.format(phase=phase, content_type=content_type)
        + "\n\n"
        + USER_PROMPT.format(context=context_block, question=query)
    )

    use_fallback = USE_FALLBACK and not args.no_fallback
    answers: list[tuple[str, str, bool]] = []

    top_chunk = contexts[0] if contexts else ""
    for model_name in resolve_models(args):
        answer        = call_ollama(prompt, model_name).strip()
        used_fallback = False

        if use_fallback and (
            looks_like_refusal(answer)
            or not is_grounded(answer, context_block)
            or has_inversion(answer, context_block)
            or has_latin_codeswitch(answer)
            or (top_chunk and has_missing_list_items(answer, top_chunk))
        ):
            answer        = extractive_answer(query, contexts)
            used_fallback = True
        if use_fallback and needs_detailed_answer(query) and len(content_tokens(answer)) < 10:
            answer        = extractive_answer(query, contexts)
            used_fallback = True
        if use_fallback and (looks_like_refusal(answer) or collapse_ws(answer) in {"", "لا اعرف"}):
            answer        = get_clarify_msg()
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
            lines += [f"== {model_name}{suffix} ==", answer, ""]
        output_text = "\n".join(lines).rstrip() + "\n"
        print("\n" + output_text)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(output_text, encoding="utf-8")


if __name__ == "__main__":
    main()
