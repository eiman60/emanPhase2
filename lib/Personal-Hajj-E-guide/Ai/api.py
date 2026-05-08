"""
Hajj Guide API — FastAPI wrapper around the RAG pipeline.

تشغيل:
    uvicorn Ai.api:app --reload --host 0.0.0.0 --port 8000

Endpoints:
    POST /ask          ← السؤال والجواب
    GET  /health       ← فحص الحالة
"""

import base64
import os
from contextlib import asynccontextmanager
from pathlib import Path

import faiss
from fastapi import FastAPI, File, Form, HTTPException, Query, Response, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sentence_transformers import SentenceTransformer

# ── تحميل الـ pipeline ──────────────────────────────────────────────────────
import sys as _sys
AI_DIR = Path(__file__).resolve().parent
_rag_dir = str(AI_DIR / "rag")
if _rag_dir not in _sys.path:
    _sys.path.insert(0, _rag_dir)

import importlib
rag = importlib.import_module("pipeline")
tr  = importlib.import_module("translation")
tts = importlib.import_module("tts")
stt = importlib.import_module("stt")

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
    lat: float | None = Field(None, example=21.4225)
    lng: float | None = Field(None, example=39.8262)
    lang: str | None = Field(None, description="ar | en | ur — auto-detected if omitted", example="en")


class AskResponse(BaseModel):
    answer: str
    used_fallback: bool = False
    phase: str = ""
    off_topic: bool = False
    fatwa: bool = False
    zone: str = ""
    lang: str = "ar"


# ── Endpoints ──────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {
        "status": "ok",
        "chunks_loaded": len(_state.get("chunks", [])),
        "model": rag.OLLAMA_MODEL,
    }


def _require_state():
    chunks    = _state.get("chunks")
    index     = _state.get("index")
    emb_model = _state.get("emb_model")
    if not chunks or index is None or emb_model is None:
        raise HTTPException(503, "Model not ready yet.")
    return chunks, index, emb_model


@app.post("/ask", response_model=AskResponse)
def ask(body: AskRequest):
    chunks, index, emb_model = _require_state()

    query_orig = body.question.strip()
    if not query_orig:
        raise HTTPException(400, "السؤال فارغ.")

    try:
        result = rag.answer_question(
            query_orig,
            chunks=chunks,
            index=index,
            emb_model=emb_model,
            lang=body.lang,
            lat=body.lat,
            lng=body.lng,
            ollama_model=body.model,
        )
    except RuntimeError as exc:
        raise HTTPException(503, f"Pipeline error: {exc}")

    return AskResponse(**result)


# ── TTS endpoint ──────────────────────────────────────────────────────────
class TtsRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=2000, example="حياك الله يا حاج")
    lang: str | None = Field(None, description="ar | en — auto-detected if omitted; ur falls back to ar")


@app.post("/tts", responses={200: {"content": {"audio/wav": {}}}})
def tts_endpoint(body: TtsRequest):
    """Synthesize Arabic or English text to a 16-bit PCM mono WAV.
    Urdu requests fall back to the Arabic voice (same script, intelligible
    if not perfectly idiomatic). Voices are lazy-loaded on first call."""
    text = body.text.strip()
    if not text:
        raise HTTPException(400, "Empty text.")

    lang = body.lang if body.lang in tr.LANGUAGES else tr.detect_language(text)
    # Urdu has no Piper voice in our config; fall back to AR (shared script).
    if not tts.is_supported(lang):
        lang = tr.AR

    try:
        wav_bytes = tts.synthesize(text, lang)
    except RuntimeError as exc:
        raise HTTPException(503, f"TTS not available: {exc}")
    except ValueError as exc:
        raise HTTPException(400, str(exc))

    if not wav_bytes:
        raise HTTPException(500, "TTS produced empty audio.")

    return Response(
        content=wav_bytes,
        media_type="audio/wav",
        headers={
            "X-TTS-Lang":            lang,
            "Content-Disposition":   'inline; filename="tts.wav"',
        },
    )


# ── Voice endpoint: STT → answer → TTS in one round-trip ─────────────────
class VoiceResponse(BaseModel):
    transcript:    str
    answer:        str
    lang:          str
    detected_lang: str = ""
    phase:         str = ""
    zone:          str = ""
    off_topic:     bool = False
    fatwa:         bool = False
    used_fallback: bool = False
    audio_b64:     str = ""   # base64 WAV; empty if with_audio=false or TTS unavailable


@app.post("/voice", response_model=VoiceResponse)
async def voice_endpoint(
    audio: UploadFile = File(..., description="Recorded audio (wav / m4a / mp3)."),
    lang: str | None = Form(None, description="Force language: ar | en | ur. If omitted, whisper auto-detects."),
    lat: float | None = Form(None),
    lng: float | None = Form(None),
    with_audio: bool = Query(True, description="Include base64 TTS audio in the response."),
):
    """Mic-button endpoint: pilgrim speaks → transcribe → answer → speak back.

    The frontend uploads the recorded clip; we transcribe with whisper,
    feed the text through the same RAG flow as /ask, and (optionally)
    return base64-encoded WAV so the client can play it without a second
    round-trip to /tts.
    """
    chunks, index, emb_model = _require_state()

    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(400, "Empty audio upload.")

    # ── STT ───────────────────────────────────────────────────────────
    try:
        transcript, detected = stt.transcribe(audio_bytes, lang=lang)
    except RuntimeError as exc:
        raise HTTPException(503, f"STT not available: {exc}")
    except Exception as exc:
        raise HTTPException(400, f"Could not decode audio: {exc}")

    transcript = (transcript or "").strip()
    user_lang  = lang if lang in tr.LANGUAGES else (detected if detected in tr.LANGUAGES else tr.detect_language(transcript))

    # Empty transcript → tell the user to retry, in their language.
    if not transcript:
        return VoiceResponse(
            transcript    = "",
            answer        = tr.localize("clarify", user_lang),
            lang          = user_lang,
            detected_lang = detected,
        )

    # ── RAG ───────────────────────────────────────────────────────────
    try:
        result = rag.answer_question(
            transcript,
            chunks=chunks,
            index=index,
            emb_model=emb_model,
            lang=user_lang,
            lat=lat,
            lng=lng,
        )
    except RuntimeError as exc:
        raise HTTPException(503, f"Pipeline error: {exc}")

    # ── TTS (optional) ────────────────────────────────────────────────
    audio_b64 = ""
    if with_audio:
        tts_lang = result["lang"] if tts.is_supported(result["lang"]) else tr.AR
        try:
            wav_bytes = tts.synthesize(result["answer"], tts_lang)
            if wav_bytes:
                audio_b64 = base64.b64encode(wav_bytes).decode("ascii")
        except (RuntimeError, ValueError):
            pass  # caller can still read the text answer

    return VoiceResponse(
        transcript    = transcript,
        detected_lang = detected,
        audio_b64     = audio_b64,
        **result,
    )
