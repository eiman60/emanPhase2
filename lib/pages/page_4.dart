import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../Personal-Hajj-E-guide/map_screen.dart';
import '../Personal-Hajj-E-guide/location_service.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  String? _lastScannedValue;
  DateTime? _lastScannedAt;
  bool _isScannerActive = false;

  void _onBarcodeDetected(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty || value == _lastScannedValue) return;

    setState(() {
      _lastScannedValue = value;
      _lastScannedAt = DateTime.now();
    });

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
            _ScannerViewport(
              isScannerActive: _isScannerActive,
              onDetect: _onBarcodeDetected,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isScannerActive = !_isScannerActive;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B33B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(_isScannerActive ? 'ايقاف المسح' : 'امسح الرمز'),
            ),
            const SizedBox(height: 14),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text('امسح الرمز لعرض التفاصيل في نافذة سفلية.'),
              ),
            ),
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

class _ScannerViewport extends StatelessWidget {
  const _ScannerViewport({required this.isScannerActive, required this.onDetect});

  final bool isScannerActive;
  final void Function(BarcodeCapture) onDetect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 380,
        child: isScannerActive
            ? MobileScanner(onDetect: onDetect)
            : Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Text(
                  'اضغط زر بدء الكاميرا',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
      ),
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
