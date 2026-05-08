"""
download_silma_gguf.py — pull SILMA-Kashif-2B-Instruct-v1.0 in GGUF format
into Ai/mobile_bundle/llm/.

Source: https://huggingface.co/silma-ai/SILMA-Kashif-2B-Instruct-v1.0-GGUF

This is the same model as the Ollama tag `silma-kashif:2b` used by the
server build, repackaged in GGUF for direct llama.cpp / fllama loading
on mobile. Default download is the Q4_K_M quant (~1.2 GB) — best size /
quality tradeoff for phone-class hardware.

Override the quant via STT-style env var:
    SILMA_QUANT=Q5_K_M  python Ai/mobile_bundle/setup/download_silma_gguf.py
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


REPO_ID  = "silma-ai/SILMA-Kashif-2B-Instruct-v1.0-GGUF"
QUANT    = os.getenv("SILMA_QUANT", "Q4_K_M")
FILENAME = f"SILMA-Kashif-2B-Instruct-v1.0.{QUANT}.gguf"

BUNDLE_DIR = Path(__file__).resolve().parents[1]
TARGET_DIR = BUNDLE_DIR / "llm"
TARGET     = TARGET_DIR / "silma-kashif-2b-q4.gguf"


def main() -> int:
    if TARGET.exists() and TARGET.stat().st_size > 100 * 1024 * 1024:
        print(f"[silma] already present: {TARGET} ({TARGET.stat().st_size // (1024*1024)} MB)")
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
    print(f"[silma] downloading {FILENAME} from {REPO_ID}")
    try:
        path = hf_hub_download(
            repo_id=REPO_ID,
            filename=FILENAME,
            local_dir=str(TARGET_DIR),
            local_dir_use_symlinks=False,
        )
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        print(
            "If the filename above doesn't exist on the HF repo, list "
            "available quants at:\n  "
            f"https://huggingface.co/{REPO_ID}/tree/main\n"
            "and re-run with SILMA_QUANT=<chosen-quant>.",
            file=sys.stderr,
        )
        return 1

    # Rename to the stable bundle name so the Flutter side has a fixed path.
    src = Path(path)
    if src != TARGET:
        src.rename(TARGET)
    print(f"\n[silma] saved to {TARGET}  ({TARGET.stat().st_size // (1024*1024)} MB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
