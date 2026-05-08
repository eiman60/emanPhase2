"""
tts.py — Piper TTS synthesis for the multilingual Hajj assistant.

Lazy-loaded like translation.py — the module stays importable even before
the voices are downloaded, so api.py can import it unconditionally and
fail at request time with a clear error if the user hasn't run setup yet.

Public surface:
    VOICE_CONFIG                  available languages → Piper voice metadata
    is_supported(lang)            does this lang have a configured voice?
    synthesize(text, lang)        return WAV bytes (16-bit PCM mono)
    unload_voices()               free voice models (Track B / on-device use)
"""

from __future__ import annotations

import io
import os
import wave
from pathlib import Path
from typing import Optional


# Voice catalog. Add new languages here; Piper voice files come from
# huggingface.co/rhasspy/piper-voices/. ar_JO-kareem is closest-to-MSA
# Arabic that Piper ships; en_US-amy is a clean female US English voice.
#
# Urdu intentionally absent — Piper's Urdu voices are limited and quality
# is uneven. We route UR requests to the AR voice (same script) at the
# api.py layer; pronunciation isn't ideal but it's intelligible.
VOICE_CONFIG: dict[str, dict[str, str]] = {
    "ar": {
        "voice_dir":   "ar_JO-kareem-medium",
        "voice_file":  "ar_JO-kareem-medium.onnx",
        "config_file": "ar_JO-kareem-medium.onnx.json",
    },
    "en": {
        "voice_dir":   "en_US-amy-medium",
        "voice_file":  "en_US-amy-medium.onnx",
        "config_file": "en_US-amy-medium.onnx.json",
    },
}

_DEFAULT_PIPER_DIR = Path(__file__).resolve().parents[1] / "models" / "piper"
PIPER_VOICES_DIR = Path(os.getenv("PIPER_VOICES_DIR", str(_DEFAULT_PIPER_DIR)))

# Loaded PiperVoice instances keyed by lang.
_voices: dict[str, object] = {}


def is_supported(lang: str) -> bool:
    return lang in VOICE_CONFIG


def _voice_paths(lang: str) -> tuple[Path, Path]:
    cfg = VOICE_CONFIG[lang]
    voice_dir = PIPER_VOICES_DIR / cfg["voice_dir"]
    return voice_dir / cfg["voice_file"], voice_dir / cfg["config_file"]


def _load_voice(lang: str):
    """Load (and cache) the Piper voice for `lang`. Raises with a clear
    message if deps or files are missing."""
    if lang in _voices:
        return _voices[lang]
    if not is_supported(lang):
        raise ValueError(f"No TTS voice configured for language: {lang!r}")

    try:
        from piper import PiperVoice  # type: ignore[import-not-found]
    except ImportError as exc:
        raise RuntimeError(
            "TTS requires piper-tts. Install with: pip install -r Ai/requirements.txt"
        ) from exc

    voice_path, config_path = _voice_paths(lang)
    if not voice_path.exists() or not config_path.exists():
        raise RuntimeError(
            f"Piper voice files for {lang!r} not found at {voice_path.parent}. "
            "Run: python Ai/setup_tts.py"
        )

    voice = PiperVoice.load(str(voice_path), config_path=str(config_path))
    _voices[lang] = voice
    return voice


def synthesize(text: str, lang: str = "ar") -> bytes:
    """Synthesize `text` to a 16-bit PCM mono WAV byte string.
    Returns b'' for empty input. Pass-through error if the voice or deps
    are missing — let the caller decide whether to 503 or fall back."""
    if not text or not text.strip():
        return b""

    voice = _load_voice(lang)

    buf = io.BytesIO()
    with wave.open(buf, "wb") as wav_f:
        voice.synthesize_wav(text, wav_f)
    return buf.getvalue()


def unload_voices() -> None:
    """Free all loaded voice models. Useful on memory-constrained devices."""
    _voices.clear()
