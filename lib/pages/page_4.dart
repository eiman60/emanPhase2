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
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFF4F5F7)),
            ),
            Positioned(
              left: -130 + (t * 28),
              bottom: 90 + (t * 28),
              child: _SoftOrb(
                diameter: 280,
                opacity: 0.7,
                blurSigma: 58,
              ),
            ),
            Positioned(
              left: -18 + ((1 - t) * 12),
              bottom: 165 + (math.sin(t * math.pi) * 18),
              child: _SoftOrb(
                diameter: 170,
                opacity: 0.5,
                blurSigma: 36,
              ),
            ),
            Center(child: child),
          ],
        );
      },
      child: const Text(
        'Page 4',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
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
