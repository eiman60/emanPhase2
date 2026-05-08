"""
ollama_pipeline.py — re-export للتوافق مع الكود القديم.
جميع الرموز منقولة إلى الملفات المتخصصة:
  text_utils.py  — معالجة النص
  knowledge.py   — قواعد المجال والبرومبتات
  location.py    — GPS وجيوفنسينج
  retrieval.py   — FAISS + BM25 + hybrid retrieve
  pipeline.py    — LLM + main()
"""

import sys as _sys
from pathlib import Path as _Path

_RAG_DIR = _Path(__file__).resolve().parent
if str(_RAG_DIR) not in _sys.path:
    _sys.path.insert(0, str(_RAG_DIR))

from text_utils import *   # noqa: F401, F403
from knowledge  import *   # noqa: F401, F403
from location   import *   # noqa: F401, F403
from retrieval  import *   # noqa: F401, F403
from pipeline   import *   # noqa: F401, F403
