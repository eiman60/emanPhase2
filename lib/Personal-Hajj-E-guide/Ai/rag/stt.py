"""
stt.py — faster-whisper transcription for the multilingual Hajj assistant.

Mirrors the lazy-load pattern used by tts.py and translation.py. The module
stays importable even before the whisper model has been downloaded; loading
happens on the first transcribe() call so api.py can import it
unconditionally and fail at request time with a clear message if the user
hasn't run setup_stt.py yet.

Public surface:
    MODEL_SIZE                    "medium" by default
    is_supported(lang)            does whisper handle this language tag?
    transcribe(audio, lang=None)  → (text, detected_lang)
    unload_model()                free the loaded model
"""

from __future__ import annotations

import io
import os
from pathlib import Path
from typing import BinaryIO, Optional, Union


MODEL_SIZE = os.getenv("STT_MODEL_SIZE", "medium")
_DEFAULT_DIR = Path(__file__).resolve().parents[1] / "models" / "whisper" / MODEL_SIZE
MODEL_DIR    = Path(os.getenv("STT_MODEL_DIR", str(_DEFAULT_DIR)))

DEVICE       = os.getenv("STT_DEVICE", "cpu")
COMPUTE_TYPE = os.getenv("STT_COMPUTE_TYPE", "int8" if DEVICE == "cpu" else "float16")

# Whisper supports far more, but we only commit to AR/EN/UR — anything else
# falls back to auto-detect.
SUPPORTED_LANGS = ("ar", "en", "ur")

_model: object | None = None


def is_supported(lang: str) -> bool:
    return lang in SUPPORTED_LANGS


def _load_model():
    """Load (and cache) the WhisperModel."""
    global _model
    if _model is not None:
        return _model

    try:
        from faster_whisper import WhisperModel  # type: ignore[import-not-found]
    except ImportError as exc:
        raise RuntimeError(
            "STT requires faster-whisper. Install with: pip install -r Ai/requirements.txt"
        ) from exc

    if not MODEL_DIR.exists() or not any(MODEL_DIR.iterdir()):
        raise RuntimeError(
            f"Whisper model not found at {MODEL_DIR}. Run: python Ai/setup_stt.py"
        )

    _model = WhisperModel(
        str(MODEL_DIR),
        device=DEVICE,
        compute_type=COMPUTE_TYPE,
        local_files_only=True,
    )
    return _model


AudioInput = Union[bytes, str, Path, BinaryIO]


def transcribe(audio: AudioInput, lang: Optional[str] = None) -> tuple[str, str]:
    """Transcribe audio and return (text, detected_lang).

    `audio` may be raw bytes (any container ffmpeg can read — wav/m4a/mp3),
    a file path, or a binary file object. `lang` is an optional hint
    ('ar' / 'en' / 'ur'); when None, whisper auto-detects.
    """
    model = _load_model()

    if isinstance(audio, bytes):
        audio = io.BytesIO(audio)

    language = lang if lang and is_supported(lang) else None

    segments, info = model.transcribe(
        audio,
        language=language,
        beam_size=5,
        vad_filter=True,
        vad_parameters={"min_silence_duration_ms": 500},
    )

    text = "".join(seg.text for seg in segments).strip()
    detected = info.language or (lang or "")
    return text, detected


def unload_model() -> None:
    global _model
    _model = None
