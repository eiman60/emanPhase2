"""
setup_stt.py — one-time download of the faster-whisper model used for STT.

Pulls a CTranslate2-converted Whisper checkpoint from HuggingFace into
Ai/models/whisper/<size>/. The default is 'medium' (~1.5 GB) which gives
acceptable Arabic and Urdu quality on CPU; override with STT_MODEL_SIZE.

Run once:
    pip install -r Ai/requirements.txt
    python Ai/setup_stt.py

Override the size:
    STT_MODEL_SIZE=small  python Ai/setup_stt.py    # ~470 MB, weak Urdu
    STT_MODEL_SIZE=large-v3  python Ai/setup_stt.py # ~3 GB, GPU recommended
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


# Systran maintains the canonical CT2 conversions used by faster-whisper.
REPO_TEMPLATE = "Systran/faster-whisper-{size}"

AI_DIR     = Path(__file__).resolve().parent
MODEL_SIZE = os.getenv("STT_MODEL_SIZE", "medium")
TARGET_DIR = AI_DIR / "models" / "whisper" / MODEL_SIZE


def main() -> int:
    try:
        from huggingface_hub import snapshot_download
    except ImportError:
        print(
            "ERROR: huggingface_hub is missing. Run:\n"
            "    pip install -r Ai/requirements.txt",
            file=sys.stderr,
        )
        return 1

    repo_id = REPO_TEMPLATE.format(size=MODEL_SIZE)
    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    print(f"[stt] downloading {repo_id} → {TARGET_DIR}")
    try:
        snapshot_download(
            repo_id=repo_id,
            local_dir=str(TARGET_DIR),
            local_dir_use_symlinks=False,
        )
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"\nDone. Whisper model at {TARGET_DIR}")
    print("Next: start the API and POST /voice with a WAV/M4A audio file.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
