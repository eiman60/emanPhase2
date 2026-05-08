import 'package:flutter/material.dart';
import '../Personal-Hajj-E-guide/map_screen.dart';
import '../Personal-Hajj-E-guide/location_service.dart';
import 'qr_scanner_page.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  DateTime? _lastScannedAt;

  Future<void> _openScanner() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (!mounted || value == null || value.isEmpty) return;
    setState(() => _lastScannedAt = DateTime.now());
    _showScannedInfoBottomSheet();
  }

  void _showScannedInfoBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: _ScannedInfoCard(scannedAt: _lastScannedAt),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              leading: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF3B33B),
                  child: Icon(Icons.person_outline, size: 25, color: Colors.white),
                ),
              ),
              actions: const [
                Icon(Icons.wallet_outlined, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.notifications_outlined, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.more_vert, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 15),
              ],
              centerTitle: true,
              title: const Text(
                'استكشاف',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, kToolbarHeight, 16, 16),
          children: [
            const _TripTimelineCard(),
            const SizedBox(height: 14),
            _ScanPromptCard(onScan: _openScanner),
            const SizedBox(height: 14),
            const _DayInfoPills(),
            const SizedBox(height: 14),
            const _DispatchCountdownCard(),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'جدول اليوم',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A6A4E),
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const _ScheduleList(),
          ],
        ),
        ),
      ),
    );
  }
}

class _ScannedInfoCard extends StatelessWidget {
  const _ScannedInfoCard({required this.scannedAt});

  final DateTime? scannedAt;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECEBFA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'م ع',
                      style: TextStyle(fontSize: 12, color: Color(0xFF403B92)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('محمد عبدالله العتيبي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('جواز: SA-4821930 | سعودي', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
              if (scannedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'وقت المسح: ${scannedAt!.toLocal()}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
              const Divider(height: 34),
              const Text('البيانات الشخصية', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 12),
              const _InfoGrid(),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8C8CF)),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('بيانات الطوارئ', style: TextStyle(fontSize: 12, color: Color(0xFF7A323B))),
                    SizedBox(height: 10),
                    Text('فصيلة الدم', style: TextStyle(fontSize: 11, color: Color(0xFF7A323B))),
                    Text('+A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    SizedBox(height: 10),
                    Text('هاتف الطوارئ', style: TextStyle(fontSize: 11, color: Color(0xFF7A323B))),
                    Text('0559876543', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('أمراض / حساسية', style: TextStyle(fontSize: 11, color: Color(0xFF7A323B))),
                    Text('ضغط الدم — يتناول دواء يوميًا', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanPromptCard extends StatelessWidget {
  const _ScanPromptCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFB9B5AA),
        radius: 18,
        strokeWidth: 1.4,
        dashWidth: 6,
        dashGap: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 30,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'امسح بطاقة حملتك',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'للحصول على جدولك الشخصي ومواعيد تفويجك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF7A7A7A),
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text(
                  'مسح الآن',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap;
}

class _DayInfoPills extends StatelessWidget {
  const _DayInfoPills();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: const [
          _InfoPill(
            icon: Icons.calendar_today_outlined,
            text: 'اليوم التاسع - يوم عرفة',
          ),
          SizedBox(width: 8),
          _InfoPill(
            icon: Icons.location_on_outlined,
            text: 'أنت الآن في: عرفات',
          ),
          SizedBox(width: 8),
          _InfoPill(
            icon: Icons.access_time,
            text: 'الوقت الحالي',
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1F1F1F),
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: const Color(0xFF8A6A4E)),
        ],
      ),
    );
  }
}

class _DispatchCountdownCard extends StatelessWidget {
  const _DispatchCountdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: Color(0xFFE0BD7A), width: 3),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'موعد تفويج حملتك إلى مزدلفة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Almarai',
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.directions_bus,
                size: 18,
                color: Color(0xFF6F4E37),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F0EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '02 : 45 : 00',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE4DC),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'يرجى التجمع في نقطة الانطلاق قبل الموعد بـ ٣٠ دقيقة',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6F4E37),
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.info_outline, size: 14, color: Color(0xFF6F4E37)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList();

  static const List<({String time, String period, String title, String subtitle})> _items = [
    (time: '05:30', period: 'ص', title: 'صلاة الفجر', subtitle: 'في مخيم الحملة'),
    (time: '09:00', period: 'ص', title: 'الاستماع لخطبة عرفة', subtitle: 'مسجد نمرة أو المخيم'),
    (time: '12:30', period: 'ظ', title: 'صلاة الظهر والعصر', subtitle: 'جمع تقديم'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _items[i].title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1F1F),
                          fontFamily: 'Almarai',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A8A8A),
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFEDEDED),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _items[i].time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8A6A4E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].period,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8A6A4E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (i != _items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid();

  @override
  Widget build(BuildContext context) {
    final itemStyle = BoxDecoration(
      color: const Color(0xFFF1F0EA),
      borderRadius: BorderRadius.circular(16),
    );

    Widget item(String title, String value) {
      return Container(
        decoration: itemStyle,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: item('تاريخ الميلاد', '15/03/1965')), const SizedBox(width: 10), Expanded(child: item('الجنس', 'ذكر'))]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: item('رقم تصريح الحج', 'HJ-2025-00471')), const SizedBox(width: 10), Expanded(child: item('مقر الإقامة', 'فندق أجياد - مكة'))]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: item('قائد البعثة', 'أحمد الشمري')), const SizedBox(width: 10), Expanded(child: item('هاتف المشرف', '0501234567'))]),
      ],
    );
  }
}

class _TripTimelineCard extends StatefulWidget {
  const _TripTimelineCard();

  @override
  State<_TripTimelineCard> createState() => _TripTimelineCardState();
}

class _TripTimelineCardState extends State<_TripTimelineCard> {
  final LocationService _locationService = LocationService();
  String _currentZone = 'جاري تحديد الموقع...';
  bool _isLoading = true;

  static const List<String> _hajjOrder = [
    'منى',
    'عرفات',
    'مزدلفة',
    'الحرم المكي',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentZone();
  }

  Future<void> _loadCurrentZone() async {
    setState(() {
      _isLoading = true;
    });

    final zone = await _locationService.checkUserZone();
    if (!mounted) return;

    setState(() {
      _currentZone = zone;
      _isLoading = false;
    });
  }

  Color _dotColorForStep(int stepIndex) {
    final currentIndex = _hajjOrder.indexOf(_currentZone);
    if (currentIndex == -1) return const Color(0xFFCACACA);
    if (stepIndex < currentIndex) return const Color(0xFF3BAF5D);
    if (stepIndex == currentIndex) return const Color(0xFFF2BE2E);
    return const Color(0xFFCACACA);
  }

  Future<void> _chooseLocationFromMap() async {
    final selectedZone = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (!mounted || selectedZone == null) return;
    await _loadCurrentZone();
  }

  Future<void> _clearManualSelection() async {
    LocationService.clearManualZoneOverride();
    await _loadCurrentZone();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _hajjOrder.indexOf(_currentZone);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مناسك الحج بالترتيب',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191919),
            ),
          ),
          const SizedBox(height: 18),
          _HorizontalTimeline(
            steps: [
              for (var i = 0; i < _hajjOrder.length; i++)
                _TimelineStep(
                  label: _hajjOrder[i],
                  color: _dotColorForStep(i),
                  isCurrent: i == currentIndex,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isLoading
                      ? 'جاري تحديث حالتك...'
                      : 'موقعك الحالي: $_currentZone',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadCurrentZone,
                icon: const Icon(Icons.refresh,
                    size: 20, color: Color(0xFF545454)),
                tooltip: 'تحديث الموقع',
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _chooseLocationFromMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('اختيار الموقع من الخريطة'),
                ),
              ),
              if (LocationService.manualZoneOverride != null)
                TextButton.icon(
                  onPressed: _clearManualSelection,
                  icon: const Icon(Icons.gps_fixed, size: 18),
                  label: const Text('العودة للموقع الحقيقي'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.color,
    required this.isCurrent,
  });

  final String label;
  final Color color;
  final bool isCurrent;
}

class _HorizontalTimeline extends StatelessWidget {
  const _HorizontalTimeline({required this.steps});

  final List<_TimelineStep> steps;

  static const double _dotSize = 14;
  static const double _lineHeight = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: steps[i].color,
                  border: steps[i].isCurrent
                      ? Border.all(
                          color: const Color(0xFFF2BE2E).withAlpha(80),
                          width: 3,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                steps[i].label,
                style: TextStyle(
                  fontSize: 12,
                  color: steps[i].isCurrent
                      ? const Color(0xFF1D1D1D)
                      : const Color(0xFF7A7A7A),
                  fontWeight: steps[i].isCurrent
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
          if (i != steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6)
                    .copyWith(top: _dotSize / 2 - _lineHeight / 2),
                child: Container(
                  height: _lineHeight,
                  color: const Color(0xFFD8D6D1),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
