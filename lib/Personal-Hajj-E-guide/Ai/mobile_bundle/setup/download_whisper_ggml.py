"""
download_whisper_ggml.py — pull a whisper.cpp-format Arabic checkpoint
into Ai/mobile_bundle/whisper/.

Default: ggml-small.bin (~470 MB). Decent Arabic STT on phone-class
CPUs. Override with WHISPER_GGML_SIZE for a different size:
    WHISPER_GGML_SIZE=tiny    →  ~75 MB,  weak Arabic
    WHISPER_GGML_SIZE=small   →  ~470 MB, good (default)
    WHISPER_GGML_SIZE=medium  →  ~1.5 GB, better but slow on phone

Whisper.cpp ggml format ≠ faster-whisper's CTranslate2 format. The
server build uses CT2 (Ai/models/whisper/medium/); this is its mobile
equivalent, fetched from a separate HF repo.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


REPO_ID  = "ggerganov/whisper.cpp"
SIZE     = os.getenv("WHISPER_GGML_SIZE", "small")
FILENAME = f"ggml-{SIZE}.bin"

BUNDLE_DIR = Path(__file__).resolve().parents[1]
TARGET_DIR = BUNDLE_DIR / "whisper"
TARGET     = TARGET_DIR / FILENAME


def main() -> int:
    if TARGET.exists() and TARGET.stat().st_size > 50 * 1024 * 1024:
        print(f"[whisper] already present: {TARGET} ({TARGET.stat().st_size // (1024*1024)} MB)")
        return 0

    try:
        from huggingface_hub import hf_hub_download
    except ImportError:
        print(
            "ERROR: huggingface_hub is missing. Run:\n"
            "    pip install -U huggingface_hub",
            file=sys.stderr,
        )
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    print(f"[whisper] downloading {FILENAME} from {REPO_ID}")
    try:
        path = hf_hub_download(
            repo_id=REPO_ID,
            filename=FILENAME,
            local_dir=str(TARGET_DIR),
            local_dir_use_symlinks=False,
        )
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"\n[whisper] saved to {path}  ({Path(path).stat().st_size // (1024*1024)} MB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
