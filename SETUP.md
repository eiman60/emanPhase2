# Setup — running the Hajj AI unit from a fresh clone

This guide gets the AI service from `git clone` to a working `POST /ask`
and `POST /voice` endpoint on Windows or Linux/macOS.

The service is Python (FastAPI + Ollama for the LLM, FAISS for retrieval,
faster-whisper + Piper for voice). All models run **locally** — there are
no cloud API calls at runtime. The first-time setup downloads ~5 GB of
model weights; after that, no network is required.

## 1. Prerequisites

| Tool | Why | Install |
|---|---|---|
| Python 3.10+ | runtime | https://www.python.org/downloads/ |
| Ollama | LLM serving | https://ollama.com/download |
| Git | clone / pull | https://git-scm.com/downloads |
| ~6 GB free disk | model weights | — |

Verify:
```bash
python --version       # 3.10 or higher
ollama --version
```

## 2. Clone and install Python deps

```bash
git clone <repo-url> Personal-Hajj-E-guide
cd Personal-Hajj-E-guide
pip install -r Ai/requirements.txt
```

## 3. Pull the LLM (Ollama)

```bash
ollama pull silma-kashif:2b
```

`silma-kashif:2b` is the Arabic-instruction-tuned Gemma2 variant the system
uses for generation. ~1.5 GB. Make sure Ollama is running (`ollama serve`
in a separate shell, or the desktop app's tray icon is active).

## 4. Download model weights (one-time, ~3 GB)

The repo deliberately ships **without** model weights — they're regenerated
by the four setup scripts below. Each is **idempotent**: re-running is a
no-op if the artifact is already in place.

```bash
# Embedding model — multilingual e5-small (~470 MB)
# (No setup script; one HF download.)
pip install -U huggingface_hub
huggingface-cli download intfloat/multilingual-e5-small \
    --local-dir Ai/models/multilingual-e5-small

# Translation (NLLB-200 distilled, CTranslate2 int8 — ~600 MB)
python Ai/setup_translation.py

# Text-to-speech (Piper Arabic + English voices — ~130 MB)
python Ai/setup_tts.py

# Speech-to-text (faster-whisper medium — ~1.5 GB)
python Ai/setup_stt.py
```

If a download fails partway, just re-run the script — it picks up where it
left off.

## 5. Build the FAISS index from the corpus

The processed chunks and FAISS index are also git-ignored. Rebuild them
from the raw Arabic Hajj corpus:

```bash
python Ai/Knowledge_base/build_index.py
```

This produces:
- `Ai/Knowledge_base/processed_chunks/hajj_ar_chunks.jsonl`
- `Ai/Knowledge_base/processed_chunks/hajj_ar_faiss.index`
- `Ai/Knowledge_base/processed_chunks/hajj_ar_metadata.json`

Takes ~2 minutes.

## 6. Run the API

```bash
uvicorn Ai.api:app --host 0.0.0.0 --port 8000 --reload
```

You should see:
```
[API] Loaded N chunks — ready.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

## 7. Smoke-test

Health check:
```bash
curl http://localhost:8000/health
```

Ask a question (Arabic, English, or Urdu — the system auto-detects and
translates internally):
```bash
curl -X POST http://localhost:8000/ask \
  -H "Content-Type: application/json" \
  -d "{\"question\": \"ايش خطوات الحج؟\"}"
```

Voice endpoint (mic upload — requires a `.wav` / `.m4a` / `.mp3` file):
```bash
curl -X POST http://localhost:8000/voice \
  -F "audio=@my_question.wav"
```

## 8. Flutter integration — wiring the chatbot page to the API

The mobile app talks to this service over HTTP. There are four
endpoints; the chatbot page typically uses `/ask` for typed questions
and `/voice` for the mic button.

### Base URL

When developing locally, the Flutter app should hit the AI backend at:
- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://localhost:8000`
- Physical device on the same Wi-Fi: `http://<dev-machine-IP>:8000`

(The API binds to `0.0.0.0:8000` so anything on the LAN can reach it.)

### `POST /ask` — typed question

Request:
```json
{
  "question": "ايش خطوات الحج؟",
  "lang":     "ar",            // optional: ar | en | ur — auto-detected if omitted
  "lat":      21.4225,         // optional GPS for zone-aware retrieval
  "lng":      39.8262          // optional
}
```

Response:
```json
{
  "answer":         "...",
  "lang":           "ar",
  "phase":          "الإحرام",
  "zone":           "haram",
  "off_topic":      false,
  "fatwa":          false,
  "used_fallback":  false
}
```

Dart sketch:
```dart
final res = await http.post(
  Uri.parse('$baseUrl/ask'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'question': userText}),
);
final body = jsonDecode(utf8.decode(res.bodyBytes));
displayAnswer(body['answer']);
```

### `POST /voice` — mic button (multipart upload)

Request: a `multipart/form-data` with the recorded audio (any common
container — wav, m4a, mp3 — ffmpeg/PyAV decodes them server-side).

Optional fields: `lang`, `lat`, `lng` (same as `/ask`).
Optional query param: `?with_audio=false` to skip TTS in the response
(saves ~50 KB if the client will play TTS itself via `/tts`).

Response:
```json
{
  "transcript":     "ايش خطوات الحج؟",
  "answer":         "...",
  "lang":           "ar",
  "detected_lang":  "ar",
  "phase":          "الإحرام",
  "zone":           "",
  "off_topic":      false,
  "fatwa":          false,
  "used_fallback":  false,
  "audio_b64":      "<base64-encoded WAV — decode and play>"
}
```

Dart sketch:
```dart
final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/voice'));
req.files.add(await http.MultipartFile.fromPath('audio', recordedFilePath));
final res = await http.Response.fromStream(await req.send());
final body = jsonDecode(utf8.decode(res.bodyBytes));

// Show the transcript + answer in the chat bubble.
displayTranscript(body['transcript']);
displayAnswer(body['answer']);

// Play the spoken answer.
final wav = base64Decode(body['audio_b64']);
await audioPlayer.play(BytesSource(wav));
```

If the user's audio is silent or unintelligible, `transcript` comes back
empty and `answer` is a localized "could not understand, please rephrase"
message. No HTTP error — handle as a normal response.

### `POST /tts` — text → audio (used if you skip `/voice`'s audio_b64)

Request:
```json
{ "text": "حياك الله يا حاج", "lang": "ar" }
```

Response: `audio/wav` body. The `X-TTS-Lang` response header echoes the
language the voice used (Urdu requests fall back to the Arabic voice).

### `GET /health` — readiness check

Use this on app launch to show a "backend offline" banner if the AI
service isn't reachable yet (Ollama still warming, FAISS still loading).

```dart
final res = await http.get(Uri.parse('$baseUrl/health'));
final ok = res.statusCode == 200 && jsonDecode(res.body)['status'] == 'ok';
```

### CORS

The API allows all origins by default. To restrict, set
`ALLOWED_ORIGINS=https://your-app-domain` before launching uvicorn.

### Error contract

All endpoints return:
- `400` — bad input (empty question, unsupported audio format)
- `503` — backend not ready or model load failed
- `200` with `off_topic=true` / `fatwa=true` — the system *answered* but
  routed to a refusal/deflection, not an error

The Flutter side should not treat `off_topic=true` or `fatwa=true` as
errors — the `answer` field is the right text to show the user.

---

## 9. Eval scripts (not in this repo)

The RAGAS / retrieval-benchmark / multilingual-eval scripts and the
paper's metric CSVs live on the AI lead's machine, not in this repo.
They are not needed to run the API. If you want to reproduce paper
numbers, ask the AI lead for the `Ai/tests/` snapshot.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `FAISS index not found` at API startup | run step 5 (`build_index.py`) |
| `Embedding model not found` | re-run the `huggingface-cli download` line in step 4 |
| `Connection refused` to Ollama | start `ollama serve` in another terminal |
| `Model not ready yet` from `/ask` | the API is still loading at startup — wait ~10 s after launch |
| TTS fails with `Piper voice files not found` | re-run `python Ai/setup_tts.py` |
| STT fails with `Whisper model not found` | re-run `python Ai/setup_stt.py` |

## Optional: on-device (Arabic-only) build

`Ai/mobile_bundle/` contains the scaffold for a fully on-device Arabic
build (no server, no translation). See `Ai/mobile_bundle/README.md` for
details. **Do not** run those setup scripts unless you're actively
developing the Flutter app — they download an additional ~2 GB of
mobile-format models.
