"""
copy_piper_voice.py — copy the existing Piper Arabic voice files from
the server build into the mobile bundle.

The server build keeps Piper voices at Ai/models/piper/ar_JO-kareem-medium/
(populated by Ai/setup_tts.py). The Piper format is ONNX which already
runs on mobile via the same plugin family — no conversion needed, just
duplicate the files into the mobile bundle for self-contained packaging.
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path


AI_DIR     = Path(__file__).resolve().parents[2]
SOURCE_DIR = AI_DIR / "models" / "piper" / "ar_JO-kareem-medium"
TARGET_DIR = Path(__file__).resolve().parents[1] / "tts"

FILES = [
    "ar_JO-kareem-medium.onnx",
    "ar_JO-kareem-medium.onnx.json",
]


def main() -> int:
    if not SOURCE_DIR.exists():
        print(
            f"ERROR: source voice not found at {SOURCE_DIR}\n"
            "Run: python Ai/setup_tts.py  (downloads the Piper voices)",
            file=sys.stderr,
        )
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    for name in FILES:
        src = SOURCE_DIR / name
        dst = TARGET_DIR / name
        if not src.exists():
            print(f"ERROR: missing {src}", file=sys.stderr)
            return 1
        if dst.exists() and dst.stat().st_size == src.stat().st_size:
            print(f"[piper] already present: {name}  ({dst.stat().st_size // 1024} KB)")
            continue
        print(f"[piper] copying {name}  ({src.stat().st_size // 1024} KB)")
        shutil.copy2(src, dst)

    print(f"\n[piper] voice ready at {TARGET_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
