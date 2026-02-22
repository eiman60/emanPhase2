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
                          _AiPromptCard(),
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
          child: AssetIconView(assetPath: AppIcons.user, size: 16),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'ahmed',
            style: TextStyle(
              color: Color(0xFFEDEDED),
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
          child: const Center(child: AssetIconView(assetPath: AppIcons.cube, size: 34)),
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
        color: Color(0xFFF1F0EC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Container(
        height: 280,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
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
              decoration: BoxDecoration(color: const Color(0xFFE7E8EC), borderRadius: BorderRadius.circular(20)),
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
          const Row(
            children: [
              Expanded(
                child: Text(
                  'اكتشف المزيد',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 42,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text('Services', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _ServiceTile(icon: Icons.explore_outlined, label: 'استكشاف'),
                    SizedBox(height: 8),
                    _ServiceTile(icon: Icons.bed_outlined, label: 'الفنادق'),
                    SizedBox(height: 8),
                    _ServiceTile(icon: Icons.spa_outlined, label: 'السبحة'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: const [
                    _ServiceTile(icon: Icons.menu_book_outlined, label: 'الصلاة'),
                    SizedBox(height: 8),
                    _ServiceTile(icon: Icons.restaurant_outlined, label: 'المطاعم'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: _TallFlightCard()),
            ],
          ),
          const SizedBox(height: 8),
          const _TrainCard(),
        ],
      ),
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
        color: selected ? const Color(0xFF3E2723) : const Color(0xFFF5F5F6),
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
      height: 76,
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

class _TallFlightCard extends StatelessWidget {
  const _TallFlightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 244,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFE3E7ED), borderRadius: BorderRadius.circular(6)),
            child: const Text('New', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
          ),
          const Spacer(),
          const Align(
            child: Icon(Icons.flight_outlined, color: Color(0xFF3F83F8), size: 38),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الطيران',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Color(0xFF1F2937), fontSize: 24, fontFamily: 'Amiri', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainCard extends StatelessWidget {
  const _TrainCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFFD8F0E7)),
                child: const Icon(Icons.train_outlined, size: 17, color: Color(0xFF059669)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE3E7ED), borderRadius: BorderRadius.circular(6)),
                child: const Text('Popular', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'قطار الحرمين',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Color(0xFF1F2937), fontSize: 24, fontFamily: 'Amiri', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPromptCard extends StatelessWidget {
  const _AiPromptCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(12),
          border: const Border(top: BorderSide(color: Color(0xFF10B981), width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFE5F7EF), borderRadius: BorderRadius.circular(14)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_outlined, color: Color(0xFF059669), size: 14),
                  SizedBox(width: 4),
                  Text('Try Nusuk AI', style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help me plan my upcoming journey.',
              style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: const Row(
                children: [
                  Text('Ask and plan your journey', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Spacer(),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
