"""
convert_e5_to_onnx.py — convert the existing multilingual-e5-small
SentenceTransformer model to ONNX so it runs in onnxruntime-mobile on
the phone.

Source: Ai/models/multilingual-e5-small/ (from the server build)
Target: Ai/mobile_bundle/embeddings/e5-small.onnx
        Ai/mobile_bundle/embeddings/tokenizer/  (HF tokenizer files)

Uses `optimum`'s ORTModelForFeatureExtraction exporter. Quantizing to
int8 is a good follow-up (cuts size from ~470 MB → ~120 MB) but kept
optional here so the Flutter side gets a known-good fp32 baseline first.

Run:
    pip install -U optimum onnx onnxruntime
    python Ai/mobile_bundle/setup/convert_e5_to_onnx.py
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path


AI_DIR     = Path(__file__).resolve().parents[2]
SOURCE_DIR = AI_DIR / "models" / "multilingual-e5-small"
TARGET_DIR = Path(__file__).resolve().parents[1] / "embeddings"
TOKENIZER_DIR = TARGET_DIR / "tokenizer"
ONNX_PATH  = TARGET_DIR / "e5-small.onnx"


def main() -> int:
    if not SOURCE_DIR.exists():
        print(
            f"ERROR: source model not found at {SOURCE_DIR}\n"
            "Download it with the server-build setup (see CLAUDE.md), or "
            "set EMBEDDING_MODEL_PATH and re-run.",
            file=sys.stderr,
        )
        return 1

    if ONNX_PATH.exists() and ONNX_PATH.stat().st_size > 50 * 1024 * 1024:
        print(f"[e5] already present: {ONNX_PATH} ({ONNX_PATH.stat().st_size // (1024*1024)} MB)")
        return 0

    try:
        from optimum.onnxruntime import ORTModelForFeatureExtraction
        from transformers import AutoTokenizer
    except ImportError as exc:
        print(
            f"ERROR: missing dependency for ONNX export: {exc}\n"
            "Run:  pip install -U optimum[onnxruntime]",
            file=sys.stderr,
        )
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    print(f"[e5] exporting {SOURCE_DIR.name} → ONNX")

    # `export=True` forces a fresh export; the HF cache may already
    # contain a converted version we don't want here.
    model = ORTModelForFeatureExtraction.from_pretrained(
        str(SOURCE_DIR),
        export=True,
        local_files_only=True,
    )
    tokenizer = AutoTokenizer.from_pretrained(str(SOURCE_DIR), local_files_only=True)

    # Save the ONNX model and the tokenizer side-by-side. The Flutter
    # ONNX runtime needs the tokenizer files (vocab + config) to encode
    # query / passage text the same way the server side does.
    tmp_dir = TARGET_DIR / "_tmp_export"
    tmp_dir.mkdir(exist_ok=True)
    model.save_pretrained(str(tmp_dir))
    tokenizer.save_pretrained(str(TOKENIZER_DIR))

    # Move the actual .onnx file to the canonical name.
    exported = tmp_dir / "model.onnx"
    if not exported.exists():
        # newer optimum may use a different filename
        for cand in tmp_dir.glob("*.onnx"):
            exported = cand
            break
    if not exported.exists():
        print(f"ERROR: optimum did not produce a .onnx file in {tmp_dir}", file=sys.stderr)
        return 1
    shutil.move(str(exported), str(ONNX_PATH))

    # Clean up the optimum tmp dir.
    shutil.rmtree(tmp_dir, ignore_errors=True)

    print(f"\n[e5] ONNX  → {ONNX_PATH}  ({ONNX_PATH.stat().st_size // (1024*1024)} MB)")
    print(f"[e5] tokenizer → {TOKENIZER_DIR}")
    print(
        "\nNext (optional): quantize to int8 for ~4x size reduction:\n"
        "    optimum-cli onnxruntime quantize "
        f"--onnx_model {ONNX_PATH} --avx512 -o {TARGET_DIR / 'e5-small-int8.onnx'}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
