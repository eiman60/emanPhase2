"""
precompute_chunk_embeddings.py — embed every corpus chunk once and write
the matrix as .npy so the Flutter app never has to run the embedding
model on the corpus side. Only query embeddings happen on device.

Inputs:
    Ai/Knowledge_base/processed_chunks/hajj_ar_chunks.jsonl
    Ai/models/multilingual-e5-small/  (server-build embedding model)

Outputs:
    Ai/mobile_bundle/corpus/hajj_ar_chunks.jsonl     (copy)
    Ai/mobile_bundle/corpus/chunk_embeddings.npy     (float32, [N, 384])
    Ai/mobile_bundle/corpus/chunk_index.json         (chunk_id → row index map)

The Flutter app:
  1. Loads chunk_embeddings.npy at startup (~2 MB for ~500 chunks)
  2. Loads hajj_ar_chunks.jsonl for chunk text + metadata
  3. For each query: embeds via onnxruntime → cosine vs the matrix →
     top-K indices → look up in jsonl

No FAISS. Brute-force cosine over a few hundred chunks finishes in a
few ms on a phone, faster than any index-build cost would amortize.
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path


AI_DIR        = Path(__file__).resolve().parents[2]
SOURCE_CHUNKS = AI_DIR / "Knowledge_base" / "processed_chunks" / "hajj_ar_chunks.jsonl"
SOURCE_MODEL  = AI_DIR / "models" / "multilingual-e5-small"

TARGET_DIR    = Path(__file__).resolve().parents[1] / "corpus"
CHUNKS_OUT    = TARGET_DIR / "hajj_ar_chunks.jsonl"
EMB_OUT       = TARGET_DIR / "chunk_embeddings.npy"
INDEX_OUT     = TARGET_DIR / "chunk_index.json"


def main() -> int:
    if not SOURCE_CHUNKS.exists():
        print(f"ERROR: chunks file not found: {SOURCE_CHUNKS}", file=sys.stderr)
        print("       Run: python Ai/Knowledge_base/build_index.py", file=sys.stderr)
        return 1
    if not SOURCE_MODEL.exists():
        print(f"ERROR: embedding model not found: {SOURCE_MODEL}", file=sys.stderr)
        return 1

    if EMB_OUT.exists() and CHUNKS_OUT.exists():
        print(f"[corpus] already precomputed at {TARGET_DIR}")
        return 0

    try:
        import numpy as np
        from sentence_transformers import SentenceTransformer
    except ImportError as exc:
        print(f"ERROR: missing dependency: {exc}", file=sys.stderr)
        print("       pip install -r Ai/requirements.txt", file=sys.stderr)
        return 1

    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    # ── load chunks ───────────────────────────────────────────────────
    chunks = []
    with SOURCE_CHUNKS.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            chunks.append(json.loads(line))
    print(f"[corpus] loaded {len(chunks)} chunks from {SOURCE_CHUNKS.name}")

    # ── load model & embed ────────────────────────────────────────────
    model = SentenceTransformer(str(SOURCE_MODEL), local_files_only=True)
    # e5 expects "passage:" prefix on indexed text — match what the
    # server-side build_index.py does so query/passage spaces align.
    texts = [
        "passage: " + (c.get("text_for_embedding") or c.get("text") or "")
        for c in chunks
    ]
    print(f"[corpus] embedding {len(texts)} chunks...")
    emb = model.encode(
        texts,
        batch_size=32,
        normalize_embeddings=True,
        show_progress_bar=True,
    )
    emb = np.asarray(emb, dtype=np.float32)
    print(f"[corpus] embedding matrix: {emb.shape}  ({emb.nbytes // 1024} KB)")

    # ── save ──────────────────────────────────────────────────────────
    np.save(EMB_OUT, emb)
    shutil.copy2(SOURCE_CHUNKS, CHUNKS_OUT)

    # Compact index for quick chunk-id → row lookup on the Flutter side.
    index = {
        c.get("id") or c.get("chunk_id") or str(i): i
        for i, c in enumerate(chunks)
    }
    INDEX_OUT.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"\n[corpus] embeddings → {EMB_OUT}")
    print(f"[corpus] chunks     → {CHUNKS_OUT}")
    print(f"[corpus] index      → {INDEX_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
