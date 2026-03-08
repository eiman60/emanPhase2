import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../widgets/top_bar.dart';
import 'emergency_report_page.dart';

class Page1Home extends StatelessWidget {
  const Page1Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFEB4548),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _QuranCard(),
            _DiscoverSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.6),
          radius: 1.35,
          colors: [
            Color(0xFF8A6A4E),
            Color(0xFF6F513A),
            Color(0xFF523A29),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: const [
          HomeTopBar(),
          SizedBox(height: 22),
          _PrayerFocus(),
          SizedBox(height: 18),
          _FeatureActions(),
        ],
      ),
    );
  }
}

class _PrayerFocus extends StatelessWidget {
  const _PrayerFocus();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            color: const Color(0xFF7A5B42),
          ),
          child: const Center(child: AssetIconView(assetPath: AppIcons.hajj, size: 34)),
        ),
        const SizedBox(height: 12),
        const Text("22 Sha'ban 1447", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        const Text(
          'Fajr 5:25 AM',
          style: TextStyle(color: Colors.white, fontSize: 47, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, color: Color(0xFFFCC83D), size: 16),
              SizedBox(width: 6),
              Text('Goodness starts with Dhikr Allah', style: TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureActions extends StatelessWidget {
  const _FeatureActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _ActionCircle(iconPath: AppIcons.rawdah, label: 'الروضة', selected: true),
        _ActionCircle(iconPath: AppIcons.hajj, label: 'الحج'),
        _ActionCircle(iconPath: AppIcons.umrah, label: 'العمره'),
        _AlertCircle(),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({required this.iconPath, required this.label, this.selected = false});

  final String iconPath;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? Colors.white.withAlpha(18) : Colors.white.withAlpha(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: AssetIconView(
              assetPath: iconPath,
              size: 24,
              iconColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 16)),
      ],
    );
  }
}

class _AlertCircle extends StatelessWidget {
  const _AlertCircle();

  void _openEmergencyReportPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EmergencyReportPage()),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'الطوارئ',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'إذا كنت بحاجة إلى المساعدة الفورية، يمكنك إرسال بلاغ طارئ الآن.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Amiri', height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Amiri', fontSize: 16)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openEmergencyReportPage(context);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEB4548)),
            child: const Text('الإبلاغ عن حالة طارئة', style: TextStyle(fontFamily: 'Amiri', fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _showEmergencyDialog(context),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66EB4548),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFEB4548),
                child: AssetIconView(assetPath: AppIcons.alert, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('الطوارئ', style: TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 16)),
      ],
    );
  }
}

class _QuranCard extends StatelessWidget {
  const _QuranCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0x614632),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Container(
        height: 280,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book_outlined, color: Color(0xFF2565EB), size: 17),
                Spacer(),
                Text(
                  'القرآن الكريم',
                  style: TextStyle(
                    color: Color(0xFF1F2938),
                    fontSize: 23,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Text('Al-Fatiha • Verse 1 • Page 1', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
            const SizedBox(height: 12),
            Container(
              width: 176,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ابدا تلاوتك',
                    style: TextStyle(
                      fontSize: 23,
                      color: Color(0xFF1F2938),
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverSection extends StatelessWidget {
  const _DiscoverSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
=======
          color: const Color(0xFFEB4548),
          borderRadius: BorderRadius.circular(24),
>>>>>>> 5d249b5c2ad377f6a78746f4b0fabb9654d914b7
        ),
        child: const Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اكتشف المزيد',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 34,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _FilterChip(label: 'All', selected: true),
                SizedBox(width: 8),
                _FilterChip(icon: Icons.nights_stay_outlined),
                SizedBox(width: 8),
                _FilterChip(icon: Icons.wallet_membership_outlined),
              ],
            ),
            SizedBox(height: 10),
            _ServiceTilesGrid(),
          ],
        ),
      ),
    );
  }
}

class _ServiceTilesGrid extends StatelessWidget {
  const _ServiceTilesGrid();

  @override
  Widget build(BuildContext context) {
    const services = [
      (Icons.explore_outlined, 'استكشاف'),
      (Icons.menu_book_outlined, 'الصلاة'),
      (Icons.restaurant_outlined, 'المطاعم'),
      (Icons.bed_outlined, 'الفنادق'),
      (Icons.spa_outlined, 'السبحة'),
      (Icons.flight_outlined, 'الطيران'),
      (Icons.train_outlined, 'القطار'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 3;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final service in services)
              SizedBox(
                width: itemWidth,
                child: _ServiceTile(icon: service.$1, label: service.$2),
              ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({this.label, this.icon, this.selected = false});

  final String? label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: selected ? const Color(0xFF3E2723) : const Color(0xFFFFFFFF),
      ),
      child: Center(
        child: label != null
            ? Text(label!, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 12))
            : Icon(icon, size: 21, color: const Color(0xFF121826)),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const Spacer(),
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 13,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
