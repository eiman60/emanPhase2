import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  late final AnimationController _scanLineController;
  bool _torchOn = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() => _processing = true);
    await _controller.stop();
    if (!mounted) return;
    final action = await showModalBottomSheet<_SheetAction>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScanSuccessSheet(),
    );
    if (!mounted) return;
    if (action == _SheetAction.viewDetails) {
      Navigator.of(context).pop(value);
    } else {
      await _controller.start();
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Container(color: Colors.black.withAlpha(60)),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.info_outline,
                      onTap: () {},
                    ),
                    const Spacer(),
                    const Text(
                      'مسح الرمز',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Almarai',
                      ),
                    ),
                    const Spacer(),
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
            Center(child: _ScannerFrame(animation: _scanLineController)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'قم بتوجيه الكاميرا نحو رمز الاستجابة السريعة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Almarai',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CircleIconButton(
                            icon: Icons.image_outlined,
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _CircleIconButton(
                            icon: _torchOn ? Icons.flash_on : Icons.flash_off,
                            iconColor: _torchOn
                                ? const Color(0xFFFFD60A)
                                : Colors.white,
                            onTap: _toggleTorch,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD60A),
                            foregroundColor: const Color(0xFF1F1F1F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 18),
                          label: const Text(
                            'التقاط الرمز',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.animation});

  final Animation<double> animation;

  static const _size = 260.0;
  static const _accent = Color(0xFFFFD60A);
  static const _cornerSize = 32.0;
  static const _cornerThickness = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: _Corner(
              size: _cornerSize,
              thickness: _cornerThickness,
              color: _accent,
              top: true,
              right: true,
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            child: _Corner(
              size: _cornerSize,
              thickness: _cornerThickness,
              color: _accent,
              top: true,
              left: true,
            ),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
              size: _cornerSize,
              thickness: _cornerThickness,
              color: _accent,
              bottom: true,
              right: true,
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
              size: _cornerSize,
              thickness: _cornerThickness,
              color: _accent,
              bottom: true,
              left: true,
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final top = 12 + (_size - 24) * animation.value;
              return Positioned(
                top: top,
                left: 8,
                right: 8,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent,
                    boxShadow: [
                      BoxShadow(color: _accent.withAlpha(140), blurRadius: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.size,
    required this.thickness,
    required this.color,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  final double size;
  final double thickness;
  final Color color;
  final bool top, bottom, left, right;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: color, width: thickness);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top ? side : BorderSide.none,
          bottom: bottom ? side : BorderSide.none,
          left: left ? side : BorderSide.none,
          right: right ? side : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(8) : Radius.zero,
          topRight: top && right ? const Radius.circular(8) : Radius.zero,
          bottomLeft: bottom && left ? const Radius.circular(8) : Radius.zero,
          bottomRight: bottom && right ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(140),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

enum _SheetAction { viewDetails, scanAnother }

class _ScanSuccessSheet extends StatelessWidget {
  const _ScanSuccessSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F5F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE6F4EA),
              ),
              child:
                  const Icon(Icons.check, size: 28, color: Color(0xFF34A853)),
            ),
            const SizedBox(height: 14),
            const Text(
              'تم المسح بنجاح',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'تم قراءة بيانات التصريح الخاص بك',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF7A7A7A),
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'رقم التصريح', value: 'PR-8472910'),
                  _DashedDivider(),
                  _InfoRow(label: 'الاسم', value: 'أحمد عبدالله'),
                  _DashedDivider(),
                  _InfoRow(label: 'الخدمة', value: 'تصريح دخول الروضة'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(_SheetAction.viewDetails),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text(
                  'عرض التفاصيل',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(_SheetAction.scanAnother),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 18,
                  color: Color(0xFF1F1F1F),
                ),
                label: const Text(
                  'مسح رمز آخر',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7A7A7A),
                fontFamily: 'Almarai',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashGap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
