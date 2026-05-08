"""
setup_translation.py — one-time download + conversion of NLLB-200-distilled-600M
into CTranslate2 int8 format.

Run once:
    pip install -r Ai/requirements-setup.txt    # huggingface_hub (transformers/torch
                                                # are already pulled in by
                                                # sentence-transformers in
                                                # Ai/requirements.txt)
    python Ai/setup_translation.py

The runtime path uses `ctranslate2` for inference, but `transformers` and `torch`
must stay installed because `sentence-transformers` (the e5 embedder loaded by
Ai/api.py) depends on them.

Output:
    Ai/models/nllb-200-distilled-600M-int8/
        model.bin                 (~600 MB, int8-quantized)
        sentencepiece.bpe.model   (tokenizer)
        config.json
        ...
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


HF_MODEL_ID = "facebook/nllb-200-distilled-600M"

AI_DIR     = Path(__file__).resolve().parent
TARGET_DIR = AI_DIR / "models" / "nllb-200-distilled-600M-int8"


def already_installed() -> bool:
    return (TARGET_DIR / "model.bin").exists() and \
           (TARGET_DIR / "sentencepiece.bpe.model").exists()


def main() -> int:
    if already_installed():
        print(f"NLLB already installed at: {TARGET_DIR}")
        print("Delete that directory if you want to re-convert.")
        return 0

    converter = shutil.which("ct2-transformers-converter")
    if converter is None:
        print(
            "ERROR: ct2-transformers-converter not on PATH.\n"
            "Install with:  pip install -r Ai/requirements.txt\n"
            "                pip install -r Ai/requirements-setup.txt",
            file=sys.stderr,
        )
        return 1

    TARGET_DIR.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {HF_MODEL_ID} and converting to int8 CT2 format...")
    print(f"Target: {TARGET_DIR}")
    print("(This downloads ~2.5 GB and writes ~600 MB. Takes a few minutes.)\n")

    cmd = [
        converter,
        "--model", HF_MODEL_ID,
        "--output_dir", str(TARGET_DIR),
        "--quantization", "int8",
        "--copy_files",
        "tokenizer.json",
        "tokenizer_config.json",
        "sentencepiece.bpe.model",
        "special_tokens_map.json",
    ]

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as exc:
        print(f"\nConversion failed (exit {exc.returncode}).", file=sys.stderr)
        return exc.returncode

    if not already_installed():
        print(
            "\nConversion finished but expected files are missing. "
            f"Inspect {TARGET_DIR}.",
            file=sys.stderr,
        )
        return 1

    print(f"\nDone. Model is at {TARGET_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
