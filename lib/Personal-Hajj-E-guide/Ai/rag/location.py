"""
location.py — GPS geofencing وتحديد منطقة الحاج
لا يعتمد على أي ملف آخر في المشروع.
مطابق لمنطق database_helper.dart في Flutter.
"""

# ── Boost للـ chunks المرتبطة بموقع المستخدم ──────────────────────────────
GPS_ZONE_BOOST = 1.8

# ── ربط كل phase بمنطقة جغرافية ───────────────────────────────────────────
# مطابق لأسماء الـ zones في database_helper.dart
PHASE_TO_ZONE: dict[int, str] = {
    0:  "general",    # أساس فقهي
    1:  "general",    # مقدمة الحج
    2:  "general",    # الإحرام (قبل الوصول)
    3:  "haram",      # الوصول إلى مكة
    4:  "haram",      # الطواف والسعي
    5:  "mina",       # منى - يوم التروية
    6:  "arafat",     # يوم عرفة
    7:  "muzdalifah", # مزدلفة
    8:  "mina",       # يوم النحر (عودة لمنى)
    9:  "mina",       # أيام التشريق
    10: "haram",      # طواف الوداع
    11: "general",    # ما بعد الحج
}

# ── إحداثيات الـ zones (polygons) ─────────────────────────────────────────
ZONE_POLYGONS: dict[str, list[tuple[float, float]]] = {
    "haram": [
        (21.4280, 39.8265), (21.4280, 39.8295),
        (21.4255, 39.8295), (21.4255, 39.8265),
    ],
    "mina": [
        (21.4165, 39.8925), (21.4165, 39.8960),
        (21.4135, 39.8960), (21.4135, 39.8925),
    ],
    "arafat": [
        (21.3505, 39.9840), (21.3505, 39.9875),
        (21.3475, 39.9875), (21.3475, 39.9840),
    ],
    "muzdalifah": [
        (21.3895, 39.9115), (21.3895, 39.9150),
        (21.3865, 39.9150), (21.3865, 39.9115),
    ],
}


def _point_in_polygon(lat: float, lng: float, polygon: list[tuple[float, float]]) -> bool:
    """Ray-casting algorithm — نفس خوارزمية maps_toolkit في Flutter."""
    n = len(polygon)
    inside = False
    j = n - 1
    for i in range(n):
        xi, yi = polygon[i]
        xj, yj = polygon[j]
        if ((yi > lng) != (yj > lng)) and (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    return inside


def detect_zone_from_gps(lat: float, lng: float) -> str:
    """
    يحدد المنطقة التي يتواجد فيها المستخدم بناءً على إحداثياته.
    يرجع: "haram" | "mina" | "arafat" | "muzdalifah" | "general"
    """
    for zone, polygon in ZONE_POLYGONS.items():
        if _point_in_polygon(lat, lng, polygon):
            return zone
    return "general"


def get_chunk_zone(chunk: dict) -> str:
    """يرجع الـ zone المرتبطة بالـ chunk بناءً على phase_number."""
    phase = chunk.get("metadata", {}).get("phase_number", -1)
    return PHASE_TO_ZONE.get(phase, "general")
