import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../app_icons.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -80,
            child: _GlowCircle(size: 280, color: Color(0x66F8D768)),
          ),
          const Positioned(
            top: 260,
            left: -110,
            child: _GlowCircle(size: 260, color: Color(0x55F8D768)),
          ),
          const Positioned(
            bottom: -100,
            right: 20,
            child: _GlowCircle(size: 220, color: Color(0x44F8D768)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 24,
              ),
              child: const Column(
                children: [
                  SizedBox(height: 8),
                  _TopRow(),
                  SizedBox(height: 30),
                  _PrayerHeader(),
                  SizedBox(height: 24),
                  _ActionRow(),
                  SizedBox(height: 26),
                  _QuranPreviewCard(),
                  SizedBox(height: 18),
                  _DhikrCard(),
                  SizedBox(height: 16),
                  _Page4SliderDots(),
                  SizedBox(height: 22),
                  _Page4AddDhikrButton(),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final transparentYellow = Color.fromARGB(0, color.red, color.green, color.blue);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.18), transparentYellow],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.notifications_none, color: Color(0xFF3B352E), size: 21),
        const SizedBox(width: 16),
        const Icon(Icons.credit_card_outlined, color: Color(0xFF3B352E), size: 21),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE7C86A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_outline, size: 24, color: Color(0xFF30291E)),
        ),
      ],
    );
  }
}

class _PrayerHeader extends StatelessWidget {
  const _PrayerHeader();

  String _toArabicDigits(String value) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var localized = value;
    for (var i = 0; i < western.length; i++) {
      localized = localized.replaceAll(western[i], arabic[i]);
    }
    return localized;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream<DateTime>.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final dateText = _toArabicDigits(
          intl.DateFormat('EEEE، d MMMM y', 'ar').format(now),
        );
        final timeText = _toArabicDigits(
          intl.DateFormat('hh:mm:ss', 'ar').format(now),
        );

        return Column(
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0EEE9),
                border: Border.all(color: const Color(0xFFE8E5DE)),
              ),
              child: const Center(
                child: AssetIconView(
                  assetPath: AppIcons.hajj,
                  size: 34,
                  iconColor: Color(0xFF3D342B),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dateText,
              style: const TextStyle(
                color: Color(0xFF8C8175),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeText,
              style: const TextStyle(
                color: Color(0xFF2F271F),
                fontSize: 66,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            const _GlassCard(
              borderRadius: 14,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 17, color: Color(0xFF948474)),
                  SizedBox(width: 8),
                  Text(
                    'الوقت الحالي',
                    style: TextStyle(
                      color: Color(0xFF7C6F60),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(label: 'الروضة', iconPath: AppIcons.rawdah),
        _ActionItem(label: 'الحج', iconPath: AppIcons.hajj),
        _ActionItem(label: 'العمره', iconPath: AppIcons.umrah),
        _AlertItem(),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.label, required this.iconPath});

  final String label;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlassCard(
          width: 70,
          height: 70,
          borderRadius: 100,
          child: Center(
            child: AssetIconView(
              assetPath: iconPath,
              size: 28,
              iconColor: const Color(0xFF2D251E),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3D342B),
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _GlassCard(
          width: 70,
          height: 70,
          borderRadius: 100,
          tint: Color(0x66EC8881),
          child: Center(
            child: AssetIconView(
              assetPath: AppIcons.alert,
              size: 28,
              iconColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'الطوارئ',
          style: TextStyle(
            color: Color(0xFF3D342B),
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuranPreviewCard extends StatelessWidget {
  const _QuranPreviewCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بِسْمِ ٱللّٰهِ ٱلرَّحْمٰنِ ٱلرَّحِيْمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              color: Color(0xFF2D251E),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'ٱلْحَمْدُ لِلّٰهِ رَبِّ ٱلْعَٰلَمِينَ ۝ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ۝ مَٰلِكِ يَوْمِ ٱلدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              color: Color(0xFF2F271F),
              height: 1.65,
            ),
          ),
          SizedBox(height: 22),
          Center(
            child: _GlassCard(
              width: 130,
              height: 48,
              borderRadius: 6,
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 22, color: Color(0xFF3A3128)),
                  SizedBox(width: 10),
                  Text(
                    'ابدا تلاوتك',
                    style: TextStyle(
                      color: Color(0xFF3A3128),
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
      tint: Color(0x55E2CDB9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'أذكار المساء',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D251E),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'اللهم بك أمسينا وبك نحيا وبك نموت وإليك المصير. اللهم إني أسألك خير هذه الليلة وخير ما بعدها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              height: 1.65,
              color: Color(0xFF2F271F),
            ),
          ),
        ],
      ),
    );
  }
}

class _Page4SliderDots extends StatelessWidget {
  const _Page4SliderDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Page4Dot(isActive: false),
        SizedBox(width: 8),
        _Page4Dot(isActive: false),
        SizedBox(width: 8),
        _Page4Dot(isActive: false),
        SizedBox(width: 8),
        _Page4Dot(isActive: true),
      ],
    );
  }
}

class _Page4Dot extends StatelessWidget {
  const _Page4Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 22 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2D251E) : const Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _Page4AddDhikrButton extends StatelessWidget {
  const _Page4AddDhikrButton();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      width: double.infinity,
      height: 62,
      child: Center(
        child: Text(
          'اضف أذكارك',
          style: TextStyle(
            color: Color(0xFF332A22),
            fontSize: 34,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 8,
    this.tint = const Color(0x66FFFFFF),
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color(0x99FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}
