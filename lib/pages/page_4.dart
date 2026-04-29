import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF3B33B),
            child: Icon(Icons.person_outline, size: 25, color: Colors.white),
          ),
        ),
        actions: const [
          Icon(Icons.wallet_outlined, size: 25, color: Color(0xFFEDEDED)),
          SizedBox(width: 8),
          Icon(Icons.notifications_outlined, size: 25, color: Color(0xFFEDEDED)),
          SizedBox(width: 8),
          Icon(Icons.more_vert, size: 25, color: Color(0xFFEDEDED)),
          SizedBox(width: 15),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, kToolbarHeight, 16, 16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 380,
                child: _isScannerActive
                    ? MobileScanner(onDetect: _onBarcodeDetected)
                    : Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Text(
                          'اضغط زر بدء الكاميرا',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
              ),
              child: Text(_isScannerActive ? 'ايقاف المسح ' : 'امسح الرمز'),
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
              child: Text(_isScannerActive ? 'ايقاف المسح ' : 'امسح الرمز'),
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
