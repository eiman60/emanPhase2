"""
Hajj Guide API — FastAPI wrapper around the RAG pipeline.

تشغيل:
    python -m uvicorn api:app --reload --host 0.0.0.0 --port 8000

Endpoints:
    POST /ask          ← السؤال والجواب
    GET  /health       ← فحص الحالة
"""

import os
from contextlib import asynccontextmanager
from pathlib import Path

import faiss
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sentence_transformers import SentenceTransformer

# ── تحميل الـ pipeline ──────────────────────────────────────────────────────
AI_DIR = Path(__file__).resolve().parent
import importlib.util

_spec = importlib.util.spec_from_file_location("rag", AI_DIR / "rag" / "ollama_pipeline.py")
rag = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rag)

# ── State يُحمَّل مرة واحدة عند البدء ─────────────────────────────────────
_state: dict = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    """تحميل الـ chunks والـ index والـ embedding model عند بدء السيرفر."""
    if not Path(rag.INDEX_PATH).exists():
        raise RuntimeError(f"FAISS index not found: {rag.INDEX_PATH}")
    if not Path(rag.CHUNKS_PATH).exists():
        raise RuntimeError(f"Chunks file not found: {rag.CHUNKS_PATH}")

    _state["chunks"] = rag.load_chunks()
    _state["index"] = faiss.read_index(str(rag.INDEX_PATH))
    _state["emb_model"] = SentenceTransformer(
        rag.EMBEDDING_MODEL_PATH,
        cache_folder=rag.HF_CACHE_DIR or None,
        local_files_only=rag.HF_LOCAL_ONLY,
    )
    print(f"[API] Loaded {len(_state['chunks'])} chunks — ready.")
    yield
    _state.clear()


# ── تهيئة التطبيق ──────────────────────────────────────────────────────────
app = FastAPI(
    title="Hajj Guide API",
    description="RAG-powered Hajj assistant — يجيب على أسئلة الحج بالعربية",
    version="1.0.0",
    lifespan=lifespan,
)

# السماح للفرونت اند بالاتصال (عدّل الـ origins حسب بيئتك)
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


# ── Schemas ────────────────────────────────────────────────────────────────
class AskRequest(BaseModel):
    question: str = Field(..., min_length=2, max_length=500, example="ايش خطوات الحج؟")
    model: str | None = Field(None, example="silma-kashif:2b")


class AskResponse(BaseModel):
    answer: str
    used_fallback: bool = False
    phase: str = ""
    off_topic: bool = False


# ── Endpoints ──────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {
        "status": "ok",
        "chunks_loaded": len(_state.get("chunks", [])),
        "model": rag.OLLAMA_MODEL,
    }


@app.post("/ask", response_model=AskResponse)
def ask(body: AskRequest):
    chunks     = _state.get("chunks")
    index      = _state.get("index")
    emb_model  = _state.get("emb_model")

    if not chunks or index is None or emb_model is None:
        raise HTTPException(503, "Model not ready yet.")

    query = body.question.strip()
    if not query:
        raise HTTPException(400, "السؤال فارغ.")

    # ── أسئلة خارج نطاق الدليل ─────────────────────────────────────────
    if rag.is_off_topic(query):
        return AskResponse(answer=rag.OFF_TOPIC_MSG, off_topic=True)

    # ── استرجاع الـ context ─────────────────────────────────────────────
    faraiz_only  = rag.is_faraiz_only_question(query)
    is_journey_q = rag.is_start_of_hajj_question(query)

    if is_journey_q:
        hits = rag.get_hajj_overview_chunks(chunks, faraiz_only=faraiz_only)
    else:
        hits = rag.hybrid_retrieve(chunks, index, query, model=emb_model)

    if not hits:
        return AskResponse(answer=rag.CLARIFY_MSG)

    contexts = [rag.chunk_text_display(chunks[idx]) for idx, _ in hits]
    if is_journey_q and not faraiz_only:
        contexts = [rag.HAJJ_JOURNEY_SUMMARY] + contexts
    context_block = rag.CONTEXT_SEPARATOR.join(contexts)

    # ── metadata للـ prompt ─────────────────────────────────────────────
    top_meta     = chunks[hits[0][0]].get("metadata", {})
    phase        = top_meta.get("phase_title", "")
    content_type = top_meta.get("content_type", top_meta.get("type", ""))

    prompt = (
        rag.SYSTEM_PROMPT.format(phase=phase, content_type=content_type)
        + "\n\n"
        + rag.USER_PROMPT.format(context=context_block, question=query)
    )

    # ── توليد الجواب ────────────────────────────────────────────────────
    model_name   = body.model or rag.OLLAMA_MODEL
    used_fallback = False

    try:
        answer = rag.call_ollama(prompt, model_name).strip()
    except Exception as exc:
        answer = ""

    if rag.USE_FALLBACK:
        if rag.looks_like_refusal(answer) or not rag.is_grounded(answer, context_block):
            answer = rag.extractive_answer(query, contexts)
            used_fallback = True
        if rag.needs_detailed_answer(query) and len(rag.content_tokens(answer)) < 10:
            answer = rag.extractive_answer(query, contexts)
            used_fallback = True
        if rag.looks_like_refusal(answer) or rag.collapse_ws(answer) in {"", "لا اعرف"}:
            answer = rag.CLARIFY_MSG
            used_fallback = True

    answer = rag.ensure_followup(answer)

    return AskResponse(
        answer=answer,
        used_fallback=used_fallback,
        phase=phase,
    )
