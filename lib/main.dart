import 'package:flutter/material.dart';

import 'app_icons.dart';

void main() {
  runApp(const NusukApp());
}

class NusukApp extends StatelessWidget {
  const NusukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const NusukHomePage(),
    );
  }
}

class NusukHomePage extends StatefulWidget {
  const NusukHomePage({super.key});

  @override
  State<NusukHomePage> createState() => _NusukHomePageState();
}

class _NusukHomePageState extends State<NusukHomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
        child: SizedBox(
          height: 60,
          child: _MainBottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 375),
                  child: const ColoredBox(
                    color: Color(0xFFF8F6F0),
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
                  ),
                ),
              ),
            )
          : SafeArea(
              child: _NavPlaceholderPage(pageIndex: _selectedIndex),
            ),
    );
  }
}

class _MainBottomNavBar extends StatelessWidget {
  const _MainBottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIconItem(
            assetPath: AppIcons.hajj,
            index: 0,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
          _NavIconItem(
            assetPath: AppIcons.image12,
            index: 1,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
          _NavIconItem(
            assetPath: AppIcons.image15,
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
          _NavIconItem(
            assetPath: AppIcons.image2,
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
          _NavIconItem(
            assetPath: AppIcons.image3,
            index: 4,
            selectedIndex: selectedIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavIconItem extends StatelessWidget {
  const _NavIconItem({
    required this.assetPath,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  final String assetPath;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? const Color(0x160E0E16) : Colors.transparent,
        ),
        child: AssetIconView(
          assetPath: assetPath,
          size: 28,
          iconColor: const Color(0xFF0E0E16),
        ),
      ),
    );
  }
}

class _NavPlaceholderPage extends StatelessWidget {
  const _NavPlaceholderPage({required this.pageIndex});

  final int pageIndex;

  static const List<String> _titles = [
    'Hajj Home',
    'Page 2',
    'Page 3',
    'Page 4',
    'Page 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _titles[pageIndex],
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AssetIconView(assetPath: AppIcons.image3, size: 28, iconColor: Color(0xFF0E0E16)),
          AssetIconView(assetPath: AppIcons.image2, size: 28, iconColor: Color(0xFF0E0E16)),
          AssetIconView(assetPath: AppIcons.image15, size: 28, iconColor: Color(0xFF0E0E16)),
          AssetIconView(assetPath: AppIcons.image12, size: 28, iconColor: Color(0xFF0E0E16)),
          AssetIconView(assetPath: AppIcons.hajj, size: 28, iconColor: Color(0xFF0E0E16)),
        ],
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
          _TopBar(),
          SizedBox(height: 22),
          _PrayerFocus(),
          SizedBox(height: 18),
          _FeatureActions(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF3B33B),
          child: Icon(Icons.person_outline, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Spacer(),
        const _TopIcon(iconPath: AppIcons.wallet, size: 19),
        const SizedBox(width: 8),
        const _TopIcon(iconPath: AppIcons.notification, size: 19),
        const SizedBox(width: 8),
        const _TopIcon(iconPath: AppIcons.menu, size: 19),
      ],
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

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.iconPath, this.size = 15});

  final String iconPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AssetIconView(
      assetPath: iconPath,
      size: size,
      iconColor: const Color(0xFFEDEDED),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
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

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFEB4548),
          child: AssetIconView(assetPath: AppIcons.alert, size: 20),
        ),
        SizedBox(height: 6),
        Text('الطوارئ', style: TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 16)),
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
      child: Column(
        children: [
          const Align(
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
          const SizedBox(height: 10),
          const Row(
            children: [
              _FilterChip(label: 'All', selected: true),
              SizedBox(width: 8),
              _FilterChip(icon: Icons.nights_stay_outlined),
              SizedBox(width: 8),
              _FilterChip(icon: Icons.wallet_membership_outlined),
            ],
          ),
          const SizedBox(height: 10),
          const _ServiceTilesGrid(),
        ],
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

