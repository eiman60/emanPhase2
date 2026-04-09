import re
import json
from pathlib import Path
from typing import List, Dict

import faiss
import numpy as np
from sentence_transformers import SentenceTransformer


# =========================
# Configuration
# =========================
BASE_DIR = Path(__file__).resolve().parent
RAW_FOLDER = "raw_data"
PROCESSED_FOLDER = "processed_chunks"
TARGET_FILENAME = "Hajj_Ar_v3.txt"

EMBEDDING_MODEL_NAME = "intfloat/multilingual-e5-small"
INDEX_FILE = "hajj_ar_faiss.index"
CHUNKS_FILE = "hajj_ar_chunks.jsonl"
METADATA_FILE = "hajj_ar_metadata.json"

ARABIC_RATIO_THRESHOLD = 0.60  # keep chunks with >=60% Arabic characters


# =========================
# Arabic helpers
# =========================
ARABIC_CHAR_RE = re.compile(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]")


def arabic_ratio(text: str) -> float:
    if not text:
        return 0.0
    arabic_chars = len(ARABIC_CHAR_RE.findall(text))
    return arabic_chars / max(len(text), 1)


def normalize_arabic(text: str) -> str:
    # Light normalization for retrieval (keep original for display)
    text = re.sub(r"[إأآٱ]", "ا", text)
    text = re.sub(r"ى", "ي", text)
    text = re.sub(r"ؤ", "و", text)
    text = re.sub(r"ئ", "ي", text)
    text = re.sub(r"ة", "ه", text)
    text = re.sub(r"ـ", "", text)  # tatweel
    text = re.sub(r"[ًٌٍَُِّْ]", "", text)  # diacritics
    return text

def requires_e5_prefix(model_name: str) -> bool:
    return "e5" in (model_name or "").lower()


def apply_passage_prefix(text: str) -> str:
    return f"passage: {text}" if requires_e5_prefix(EMBEDDING_MODEL_NAME) else text
# =========================
# Parsing
# =========================
PHASE_RE = re.compile(r"^PHASE\s+(\d+)\s*:\s*(.+)$")
STAGE_RE = re.compile(r"^STAGE\s*:\s*(.+)$")
TYPE_RE = re.compile(r"^TYPE\s*:\s*(.+)$")
STEP_RE = re.compile(r"^STEP\s+(\d+)(?:\s*\(([^)]*)\))?\s*:?$")
SEPARATOR_RE = re.compile(r"^=+$")
# =========================
# Stage Aliases
# أسئلة مرتبطة بكل chunk تُضاف لـ text_for_embedding
# تساعد النموذج يجد الـ chunk الصحيح حتى لو السؤال لا يذكر stage_title
# =========================
STAGE_ALIASES: Dict[str, List[str]] = {
    "التوجه إلى عرفات": [
        "خطوات يوم عرفة",
        "ماذا أفعل في يوم عرفة",
        "برنامج يوم عرفة",
        "ماذا يفعل الحاج في يوم التاسع",
    ],
    "الحلق والتقصير": [
        "ماذا أفعل بعد رمي جمرة العقبة",
        "ما بعد رمي الجمرة",
        "التحلل الأول كيف يحدث",
    ],
    "المواقيت المكانية": [
        "هل يجوز تجاوز الميقات بدون إحرام",
        "حكم تجاوز الميقات",
        "ما حكم من تجاوز الميقات",
    ],
    "رمي الجمرات في أيام التشريق": [
        "متى يبدأ وقت رمي الجمرات",
        "وقت رمي الجمرات في أيام التشريق",
        "ترتيب رمي الجمرات الثلاث",
        "كيف أرمي الجمرات الثلاث",
    ],
    "صفة الرمي في أيام التشريق": [
        "كيف أرمي الجمرات في أيام التشريق",
        "طريقة رمي الجمرات",
        "خطوات رمي الجمرات",
    ],
    "الإحرام من المطار": [
        "كيف أحرم من الطائرة",
        "كيف أحرم إذا سافرت جواً",
        "خطوات الإحرام من المطار",
    ],
    "كيف يقضي الحاج يوم عرفة": [
        "ماذا أفعل في عرفة",
        "كيف أستثمر يوم عرفة",
        "ما الأعمال المستحبة في عرفة",
    ],
    "التوجه إلى مزدلفة": [
        "ماذا أفعل بعد عرفة",
        "ما الذي أفعله في مزدلفة بعد عرفة",
        "خطوات مزدلفة بعد عرفة",
    ],
    "رمي جمرة العقبة": [
        "كيف أرمي جمرة العقبة",
        "طريقة رمي جمرة العقبة",
        "خطوات رمي جمرة العقبة يوم العيد",
        "كم عدد حصيات جمرة العقبة",
        "أين تقع جمرة العقبة",
    ],
}
CONTEXT_INJECT = {
    "التلبية": "التلبية لبيك اللهم لبيك ذكر الإحرام:",
    "المواقيت": "المواقيت ميقات الإحرام مكان وزمان:",
    "التمتع": "التمتع أحد أنواع النسك الثلاثة يحرم بالعمرة أولاً:",
    "الإفراد": "الإفراد أحد أنواع النسك الثلاثة يحرم بالحج فقط:",
    "القِران": "القِران أحد أنواع النسك الثلاثة ينوي الحج والعمرة معاً:",
    "القران": "القران أحد أنواع النسك الثلاثة ينوي الحج والعمرة معاً:",
}


def parse_structured_text(lines: List[str]) -> List[Dict]:
    chunks = []

    current_phase_num = None
    current_phase_title = None
    current_stage_title = None
    current_type = None
    current_content_lines = []
    current_steps = []
    current_step = None

    def finalize_step():
        nonlocal current_step, current_steps
        if not current_step:
            return
        step_text = "\n".join(current_step["lines"]).strip()
        current_steps.append(
            {
                "number": current_step["number"],
                "title": current_step["title"],
                "text": step_text,
            }
        )
        current_step = None

    def build_text_for_embedding(phase_title: str, stage_title: str, content_lines: List[str]) -> str:
        header = (stage_title or "").strip()
        cleaned = []
        for ln in content_lines:
            ln = ln.strip()
            if not ln:
                continue
            step_match = STEP_RE.match(ln)
            if step_match:
                num = step_match.group(1)
                title = (step_match.group(2) or "").strip()
                if title:
                    cleaned.append(f"خطوة {num}: {title}")
                else:
                    cleaned.append(f"خطوة {num}:")
                continue
            cleaned.append(ln)
        body = "\n".join(cleaned).strip()
        if not body:
            return ""

        # أضف aliases كسطر مكثّف في أول الـ text_for_embedding
        aliases = STAGE_ALIASES.get(header, [])
        aliases_line = " | ".join(aliases)

        inject = CONTEXT_INJECT.get(header, "")
        if inject:
            if header:
                base = f"{inject}\n{header}:\n{body}"
            else:
                base = f"{inject}\n{body}"
            return f"{aliases_line}\n{base}" if aliases_line else base
        if header:
            if len(body) < 150 and phase_title:
                base = f"{phase_title} - {header}:\n{body}"
            else:
                base = f"{header}:\n{body}"
            return f"{aliases_line}\n{base}" if aliases_line else base
        return f"{aliases_line}\n{body}" if aliases_line else body

    def flush():
        nonlocal current_content_lines, current_stage_title, current_type, current_steps, current_step
        if current_stage_title and current_content_lines:
            finalize_step()
            display_lines = []
            if current_phase_num is not None and current_phase_title:
                display_lines.append(f"PHASE {current_phase_num}: {current_phase_title}")
            display_lines.append(f"STAGE: {current_stage_title}")
            if current_type:
                display_lines.append(f"TYPE: {current_type}")
            display_lines.extend(current_content_lines)

            text_display = "\n".join(display_lines).strip()
            text_for_embedding = build_text_for_embedding(
                current_phase_title or "",
                current_stage_title or "",
                current_content_lines,
            )
            if text_for_embedding:
                chunks.append(
                    {
                        "phase_number": current_phase_num,
                        "phase_title": current_phase_title,
                        "stage_title": current_stage_title,
                        "content_type": current_type,
                        "text_display": text_display,
                        "text_for_embedding": text_for_embedding,
                        "steps": current_steps,
                        "is_procedural": bool(current_steps),
                    }
                )
        current_content_lines = []
        current_stage_title = None
        current_type = None
        current_steps = []
        current_step = None

    for line in lines:
        line = line.strip()

        if not line or SEPARATOR_RE.match(line):
            continue

        phase_match = PHASE_RE.match(line)
        if phase_match:
            # New phase; flush stage first
            flush()
            current_phase_num = int(phase_match.group(1))
            current_phase_title = phase_match.group(2).strip()
            continue

        stage_match = STAGE_RE.match(line)
        if stage_match:
            # New stage; flush previous
            flush()
            current_stage_title = stage_match.group(1).strip()
            continue

        type_match = TYPE_RE.match(line)
        if type_match:
            current_type = type_match.group(1).strip()
            continue

        # Regular content
        if current_stage_title:
            step_match = STEP_RE.match(line)
            if step_match:
                finalize_step()
                current_step = {
                    "number": int(step_match.group(1)),
                    "title": (step_match.group(2) or "").strip(),
                    "lines": [],
                }
                current_content_lines.append(line)
                continue
            current_content_lines.append(line)
            if current_step:
                current_step["lines"].append(line)

    flush()
    return chunks


# =========================
# Embedding + FAISS
# =========================


def build_faiss_index(vectors: np.ndarray) -> faiss.IndexFlatIP:
    # Vectors are already normalized by the encoder for cosine similarity
    index = faiss.IndexFlatIP(vectors.shape[1])
    index.add(vectors)
    return index


def main():
    raw_dir = BASE_DIR / RAW_FOLDER
    processed_dir = BASE_DIR / PROCESSED_FOLDER
    processed_dir.mkdir(parents=True, exist_ok=True)

    target_path = raw_dir / TARGET_FILENAME
    if not target_path.exists():
        raise FileNotFoundError(f"Target file not found: {target_path}")

    # Read file
    lines = target_path.read_text(encoding="utf-8").splitlines()

    # Parse structured chunks
    chunks = parse_structured_text(lines)

    # Arabic-only filtering (safety)
    filtered = []
    for c in chunks:
        if arabic_ratio(c["text_for_embedding"]) >= ARABIC_RATIO_THRESHOLD:
            filtered.append(c)

    if not filtered:
        raise ValueError("No Arabic chunks found after filtering.")

    # Prepare texts for embedding
    texts_for_embedding = [normalize_arabic(c["text_for_embedding"]) for c in filtered]
    texts_for_embedding = [apply_passage_prefix(t) for t in texts_for_embedding]

    # Embed
    model = SentenceTransformer(EMBEDDING_MODEL_NAME)
    embeddings = model.encode(
        texts_for_embedding,
        convert_to_numpy=True,
        show_progress_bar=True,
        normalize_embeddings=True,
    )

    # Build FAISS index
    index = build_faiss_index(embeddings)

    # Save chunks + metadata
    chunks_path = processed_dir / CHUNKS_FILE
    with chunks_path.open("w", encoding="utf-8") as f:
        for i, c in enumerate(filtered):
            record = {
                "id": i,
                "text": c["text_display"],
                "text_display": c["text_display"],
                "text_for_embedding": c["text_for_embedding"],
                "metadata": {
                    "phase_number": c["phase_number"],
                    "phase_title": c["phase_title"],
                    "stage_title": c["stage_title"],
                    "content_type": c["content_type"],
                    "type": c["content_type"],
                    "is_procedural": c["is_procedural"],
                    "steps": c["steps"],
                    "step_count": len(c["steps"]),
                    "prev_chunk_id": i - 1 if i > 0 else None,
                    "next_chunk_id": i + 1 if i < len(filtered) - 1 else None,
                    "language": "ar",
                },
            }
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    metadata_path = processed_dir / METADATA_FILE
    with metadata_path.open("w", encoding="utf-8") as f:
        json.dump(
            {
                "source_file": TARGET_FILENAME,
                "total_chunks": len(filtered),
                "embedding_model": EMBEDDING_MODEL_NAME,
                "text_fields": {
                    "display": "text_display",
                    "embedding": "text_for_embedding",
                },
            },
            f,
            ensure_ascii=False,
            indent=2,
        )

    # Save FAISS index
    index_path = processed_dir / INDEX_FILE
    faiss.write_index(index, str(index_path))

    print(f"Chunks saved to {chunks_path}")
    print(f"Metadata saved to {metadata_path}")
    print(f"FAISS index saved to {index_path}")
    print(f"Total chunks indexed: {len(filtered)}")


if __name__ == "__main__":
    main()
