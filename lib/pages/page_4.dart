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

  void _onBarcodeDetected(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty || value == _lastScannedValue) return;
    setState(() {
      _lastScannedValue = value;
      _lastScannedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 14),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF3B33B),
              child: Icon(Icons.person_outline, size: 22, color: Colors.white),
            ),
          ),
          actions: const [
            Icon(Icons.wallet_outlined, size: 22, color: Color(0xFFEDEDED)),
            SizedBox(width: 8),
            Icon(Icons.notifications_outlined,
                size: 22, color: Color(0xFFEDEDED)),
            SizedBox(width: 8),
            Icon(Icons.more_vert, size: 22, color: Color(0xFFEDEDED)),
            SizedBox(width: 15),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5C4033), Color(0xFF3E2723), Color(0xFF3E2723)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: kToolbarHeight),
                const Text(
                  'امسح باركود خارجي من ورقة أو بطاقة أو هاتف آخر.',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 280,
                    child: MobileScanner(onDetect: _onBarcodeDetected),
                  ),
                ),
                const SizedBox(height: 14),
                _lastScannedValue == null
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Text('لم يتم مسح باركود بعد.',
                              style: TextStyle(fontSize: 12)),
                        ),
                      )
                    : _ScannedInfoCard(scannedAt: _lastScannedAt),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannedInfoCard extends StatelessWidget {
  const _ScannedInfoCard({this.scannedAt});

  final DateTime? scannedAt;

  static const _label = TextStyle(fontSize: 10, color: Color(0xFF7A323B));

  Widget _item(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  child: const Text('م ع',
                      style: TextStyle(fontSize: 12, color: Color(0xFF403B92))),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('محمد عبدالله العتيبي',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('جواز: SA-4821930 | سعودي',
                          style: TextStyle(fontSize: 10, color: Colors.black87)),
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
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
            const Divider(height: 34),
            const Text('البيانات الشخصية', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _item('تاريخ الميلاد', '15/03/1965')),
                const SizedBox(width: 10),
                Expanded(child: _item('الجنس', 'ذكر')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _item('رقم تصريح الحج', 'HJ-2025-00471')),
                const SizedBox(width: 10),
                Expanded(child: _item('مقر الإقامة', 'فندق أجياد - مكة')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _item('قائد البعثة', 'أحمد الشمري')),
                const SizedBox(width: 10),
                Expanded(child: _item('هاتف المشرف', '0501234567')),
              ],
            ),
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
                  Text('بيانات الطوارئ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7A323B))),
                  SizedBox(height: 10),
                  Text('فصيلة الدم', style: _label),
                  Text('+A',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  Text('هاتف الطوارئ', style: _label),
                  Text('0559876543',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  Text('أمراض / حساسية', style: _label),
                  Text('ضغط الدم — يتناول دواء يوميًا',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
