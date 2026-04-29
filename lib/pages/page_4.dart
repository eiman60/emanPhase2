import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  final TextEditingController _barcodeInputController = TextEditingController(
    text: 'HAJJ-2026-USER-001',
  );

  String _generatedValue = 'HAJJ-2026-USER-001';
  String? _lastScannedValue;
  DateTime? _lastScannedAt;

  @override
  void dispose() {
    _barcodeInputController.dispose();
    super.dispose();
  }

  void _createBarcode() {
    final value = _barcodeInputController.text.trim();
    if (value.isEmpty) return;

    setState(() {
      _generatedValue = value;
    });
  }

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
              '1) Create a barcode\n2) Point the camera to scan\n3) Read scanned information below',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _barcodeInputController,
              decoration: const InputDecoration(
                labelText: 'Barcode content',
                hintText: 'Type any ID, URL, or text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _createBarcode,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Create Barcode'),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Barcode',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: _generatedValue,
                        width: double.infinity,
                        height: 90,
                        drawText: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 240,
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
