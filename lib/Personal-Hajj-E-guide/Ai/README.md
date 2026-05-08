# Hajj Guide AI

نظام RAG (Retrieval-Augmented Generation) للإجابة على أسئلة الحج باللغة العربية.

---

## المتطلبات

- Python 3.10+
- [Ollama](https://ollama.com) مثبّت وشغّال محلياً
- نموذج اللغة محمّل في Ollama:
  ```bash
  ollama pull silma-kashif:2b
  ```

---

## التثبيت

```bash
pip install -r Ai/requirements.txt
```

---

## هيكل المجلدات

```
Ai/
├── api.py                          # FastAPI server — نقطة الدخول للباك اند
├── run_ai.py                       # CLI للتشغيل اليدوي والتقييم
├── requirements.txt                # المكتبات المطلوبة
│
├── rag/
│   └── ollama_pipeline.py          # قلب النظام: استرجاع + توليد الإجابات
│
├── Knowledge_base/
│   ├── build_index.py              # يبني الـ FAISS index من ملفات الـ chunks
│   ├── raw_data/
│   │   └── Hajj_Ar_v3.txt          # مصدر المعرفة (نص الحج بالعربي)
│   └── processed_chunks/
│       ├── hajj_ar_chunks.jsonl    # الـ chunks المعالجة (لا ترفعها على GitHub)
│       ├── hajj_ar_faiss.index     # الـ FAISS vector index (لا ترفعه على GitHub)
│       └── hajj_ar_metadata.json
│
├── models/
│   └── multilingual-e5-small/      # نموذج الـ embedding (لا ترفعه — 470MB)
│
└── tests/
    ├── data/                       # نتائج التقييم (CSV)
    └── scripts/
        ├── eval_faq_dataset.py     # تقييم المودل على الأسئلة الشائعة
        ├── generate_answers.py     # توليد إجابات لـ dataset التقييم
        ├── eval_ragas.py           # حساب مقاييس RAGAS
        └── generate_dataset.py     # بناء dataset التقييم من الـ chunks
```

---

## تشغيل الـ API

```bash
uvicorn Ai.api:app --reload --host 0.0.0.0 --port 8000
```

### Endpoints

| Method | URL | الوصف |
|--------|-----|-------|
| `GET`  | `/health` | فحص حالة السيرفر |
| `POST` | `/ask`    | إرسال سؤال والحصول على جواب |

### مثال

```bash
curl -X POST http://localhost:8000/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "ايش خطوات الحج؟"}'
```

```json
{
  "answer": "خطوات الحج بالترتيب: (1) الإحرام...",
  "used_fallback": false,
  "phase": "الإحرام",
  "off_topic": false
}
```

---

## تشغيل الـ CLI (اختبار يدوي)

```bash
# وضع المحادثة التفاعلية
python Ai/run_ai.py rag

# سؤال مباشر
python Ai/rag/ollama_pipeline.py -q "ايش فرائض الحج؟"
```

---

## تشغيل التقييم

```bash
# تقييم المودل على أسئلة الحج الشائعة
python Ai/tests/scripts/eval_faq_dataset.py

# أول 10 أسئلة فقط (للاختبار السريع)
python Ai/tests/scripts/eval_faq_dataset.py --max-questions 10

# إعادة حساب كل الإجابات من الصفر
python Ai/tests/scripts/eval_faq_dataset.py --overwrite
```

---

## إعادة بناء الـ Index

إذا عدّلت ملف `Hajj_Ar_v3.txt`:

```bash
python Ai/Knowledge_base/build_index.py
```

---

## متغيرات البيئة

| المتغير | القيمة الافتراضية | الوصف |
|---------|-------------------|-------|
| `OLLAMA_MODEL` | `silma-kashif:2b` | اسم المودل في Ollama |
| `OLLAMA_URL` | `http://localhost:11434/api/generate` | عنوان Ollama |
| `EMBEDDING_MODEL_PATH` | `Ai/models/multilingual-e5-small` | مسار نموذج الـ embedding |
| `ALLOWED_ORIGINS` | `*` | الـ domains المسموح لها بالاتصال بالـ API |

---

## ما يُرفع على GitHub / ما لا يُرفع

| الملف/المجلد | يُرفع؟ | السبب |
|---|---|---|
| `rag/ollama_pipeline.py` | ✅ | الكود الرئيسي |
| `Knowledge_base/raw_data/` | ✅ | مصدر المعرفة |
| `api.py`, `run_ai.py` | ✅ | نقاط الدخول |
| `requirements.txt` | ✅ | المكتبات |
| `processed_chunks/` | ❌ | يُبنى تلقائياً |
| `models/` | ❌ | 470MB — يُنزَّل من HuggingFace |
| `tests/data/*.csv` | ❌ | نتائج مؤقتة |
