import 'dart:math' as math;

import 'package:flutter/material.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phaseOpacity({
    required double t,
    required double start,
    required double end,
  }) {
    if (t < start || t > end) {
      return 0;
    }

    final localT = (t - start) / (end - start);
    return Curves.easeInOut.transform(1 - ((localT - 0.5).abs() * 2));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final glow1Opacity = _phaseOpacity(t: t, start: 0.00, end: 0.45);
        final glow2Opacity = _phaseOpacity(t: t, start: 0.50, end: 0.95);

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFFF4F5F7)),
              Align(
                alignment: Alignment.bottomLeft,
                child: Transform.translate(
                  offset: Offset(16 + (t * 40), -84 - (t * 36)),
                  child: _SoftGlow(
                    size: 260,
                    color: const Color(0xFFF8D768),
                    opacity: 0.40 * glow1Opacity,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Transform.translate(
                  offset: Offset(58 + ((1 - t) * 32), -152 - (t * 22)),
                  child: _SoftGlow(
                    size: 170,
                    color: const Color(0xFFF8D768),
                    opacity: 0.30 * glow2Opacity,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Page 4',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.45),
            color.withOpacity(0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({
    required this.diameter,
    required this.opacity,
    required this.blurSigma,
  });

  final double diameter;
  final double opacity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8D768).withValues(alpha: opacity),
            blurRadius: blurSigma,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}
