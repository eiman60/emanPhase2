"""
setup_tts.py — one-time download of Piper TTS voices for the Hajj assistant.

Pulls voices from huggingface.co/rhasspy/piper-voices/. ~130 MB total for
the two voices we ship (Arabic + English).

Run once:
    pip install -r Ai/requirements.txt   # piper-tts and friends
    python Ai/setup_tts.py

After this, Ai/rag/tts.py can synthesize on demand without network access —
voices live in Ai/models/piper/<voice_name>/ and are loaded lazily on the
first /tts request.
"""

from __future__ import annotations

import sys
import urllib.error
import urllib.request
from pathlib import Path


# Each entry: voice_dir → list of (filename, hf_url) pairs.
# URLs follow the rhasspy/piper-voices repo's published layout.
_HF_BASE = "https://huggingface.co/rhasspy/piper-voices/resolve/main"

VOICES = {
    "ar_JO-kareem-medium": [
        ("ar_JO-kareem-medium.onnx",
         f"{_HF_BASE}/ar/ar_JO/kareem/medium/ar_JO-kareem-medium.onnx"),
        ("ar_JO-kareem-medium.onnx.json",
         f"{_HF_BASE}/ar/ar_JO/kareem/medium/ar_JO-kareem-medium.onnx.json"),
    ],
    "en_US-amy-medium": [
        ("en_US-amy-medium.onnx",
         f"{_HF_BASE}/en/en_US/amy/medium/en_US-amy-medium.onnx"),
        ("en_US-amy-medium.onnx.json",
         f"{_HF_BASE}/en/en_US/amy/medium/en_US-amy-medium.onnx.json"),
    ],
}

AI_DIR     = Path(__file__).resolve().parent
TARGET_DIR = AI_DIR / "models" / "piper"


def _download(url: str, dest: Path) -> None:
    """Stream a file to disk with a basic progress indicator."""
    tmp = dest.with_suffix(dest.suffix + ".part")
    try:
        with urllib.request.urlopen(url) as resp, tmp.open("wb") as out:
            total = int(resp.headers.get("Content-Length") or 0)
            written = 0
            chunk = 1024 * 256
            while True:
                buf = resp.read(chunk)
                if not buf:
                    break
                out.write(buf)
                written += len(buf)
                if total:
                    pct = 100 * written / total
                    print(f"    {written // 1024} KB / {total // 1024} KB  ({pct:5.1f}%)",
                          end="\r", flush=True)
        tmp.rename(dest)
        print()
    except Exception:
        if tmp.exists():
            tmp.unlink(missing_ok=True)
        raise


def main() -> int:
    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    for voice_name, files in VOICES.items():
        voice_dir = TARGET_DIR / voice_name
        voice_dir.mkdir(exist_ok=True)
        print(f"\n[{voice_name}]")
        for filename, url in files:
            dest = voice_dir / filename
            if dest.exists() and dest.stat().st_size > 0:
                print(f"  already present: {filename}  ({dest.stat().st_size // 1024} KB)")
                continue
            print(f"  downloading {filename}")
            try:
                _download(url, dest)
            except urllib.error.HTTPError as exc:
                print(f"  ERROR: {exc.code} {exc.reason} for {url}", file=sys.stderr)
                return 1
            except Exception as exc:
                print(f"  ERROR: {exc}", file=sys.stderr)
                return 1

    print(f"\nDone. Voices at {TARGET_DIR}")
    print("Next: start the API and POST /tts with {\"text\": \"السلام عليكم\", \"lang\": \"ar\"}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
