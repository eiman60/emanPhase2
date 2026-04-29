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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        backgroundColor: const Color(0xFFEACB6A),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Scan an existing barcode from paper, card, or another phone screen.\nThe app reads it and shows the information below.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 280,
                child: MobileScanner(
                  onDetect: _onBarcodeDetected,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF8E7),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Information',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastScannedValue ?? 'No barcode scanned yet.',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_lastScannedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Scanned at: ${_lastScannedAt!.toLocal()}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
