# Mobile bundle — Arabic-only, on-device inference

This directory packages everything a Flutter app needs to run the Hajj
assistant **fully offline on a phone**, in Arabic only. It exists in
parallel with the multilingual server build under `Ai/rag/` + `Ai/api.py`
— nothing in this directory is loaded by `uvicorn Ai.api:app`, and the
existing eval pipeline is unaffected.

If the on-device path doesn't pan out, delete this folder. Nothing else
needs to change.

## Layout

```
Ai/mobile_bundle/
├── llm/         silma-kashif Q4 GGUF for llama.cpp / fllama
├── whisper/     ggml whisper Arabic checkpoint for whisper.cpp
├── tts/         Piper Arabic ONNX voice (copy of the server-side one)
├── embeddings/  e5-small ONNX for onnxruntime-mobile
├── corpus/      hajj_ar_chunks.jsonl + precomputed chunk_embeddings.npy
└── setup/       download / convert / precompute scripts
```

All artifacts live under git-ignored extensions (`*.gguf`, `*.bin`,
`*.onnx`, `*.npy`) so this directory stays clean in version control.

## What runs where on the phone

| Component | Mobile runtime | Source artifact |
|---|---|---|
| LLM generation | `llama.cpp` (via `fllama` or `llama_cpp_dart` Flutter plugin) | `llm/silma-kashif-2b-q4.gguf` |
| Speech → text | `whisper.cpp` (via `whisper_flutter_plus` plugin) | `whisper/ggml-small.bin` |
| Text → speech | Piper (via `piper_dart` plugin or native ONNX) | `tts/ar_JO-kareem-medium.onnx` |
| Query embeddings | `onnxruntime-mobile` (Dart bindings) | `embeddings/e5-small.onnx` |
| Retrieval | brute-force cosine in pure Dart | `corpus/chunk_embeddings.npy` + `corpus/hajj_ar_chunks.jsonl` |

No FAISS on device — the corpus is small enough that a Dart loop over the
precomputed embedding matrix is faster than any index-build cost.

## What is **not** ported

- Translation (NLLB) — Arabic-only build by design
- The off-topic / fatwa keyword filters — these get re-implemented in Dart
  by porting the regexes from `Ai/rag/knowledge.py`
- The fallback chain (`extractive_answer`, etc.) — Dart port of the same
  logic in `Ai/rag/retrieval.py`

The Dart port lives in the Flutter app's repo, not here.

## Setup order (run from repo root)

```powershell
# 1. heaviest download — the LLM
python Ai/mobile_bundle/setup/download_silma_gguf.py

# 2. whisper.cpp Arabic checkpoint
python Ai/mobile_bundle/setup/download_whisper_ggml.py

# 3. lightweight: copies the existing Piper voice
python Ai/mobile_bundle/setup/copy_piper_voice.py

# 4. converts the existing e5-small to ONNX (uses optimum)
python Ai/mobile_bundle/setup/convert_e5_to_onnx.py

# 5. precomputes per-chunk embeddings → .npy + matching jsonl
python Ai/mobile_bundle/setup/precompute_chunk_embeddings.py
```

Each script is **idempotent** — re-running it is a no-op if the output
is already in place.

## Bundle size budget

| Artifact | Approx size |
|---|---|
| silma-kashif Q4 GGUF | ~1.2 GB |
| whisper ggml-small | ~470 MB |
| Piper voice | ~30 MB |
| e5-small ONNX | ~120 MB (int8) / ~470 MB (fp32) |
| corpus + embeddings | ~5 MB |
| **Total** | **~1.8–2.2 GB** |

Feasible as an APK download, especially with on-demand model fetch from
Play Store / direct URL on first launch.

## Reverting

If you decide on-device isn't working out:

```powershell
rd /s /q Ai\mobile_bundle
```

That's it. Nothing else needs to change.
