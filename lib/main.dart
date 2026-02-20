import 'package:flutter/material.dart';

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

class NusukHomePage extends StatelessWidget {
  const NusukHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E7EA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HeroSection(),
              const _QuranCard(),
              const SizedBox(height: 22),
              const _DiscoverSection(),
              const SizedBox(height: 22),
              const _AiPromptCard(),
              const SizedBox(height: 24),
            ],
          ),
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
          center: Alignment(0, -0.35),
          radius: 1.1,
          colors: [
            Color(0xFF3E5676),
            Color(0xFF1B273F),
            Color(0xFF0B1730),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF2A6DF6),
                child: Icon(Icons.person_outline, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nusuk Wallet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _TopIcon(icon: Icons.account_balance_wallet_outlined),
              const SizedBox(width: 8),
              _TopIcon(icon: Icons.notifications_none),
              const SizedBox(width: 8),
              _TopIcon(icon: Icons.grid_view_rounded),
            ],
          ),
          const SizedBox(height: 30),
          Align(
            child: Container(
              width: 165,
              height: 165,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
                gradient: const RadialGradient(
                  colors: [Color(0xFF314D70), Color(0xFF1D2E4D)],
                ),
              ),
              child: const Icon(Icons.hexagon_outlined, color: Colors.white, size: 60),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "22 Sha'ban 1447",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Fajr 5:25 AM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.white.withAlpha(31),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, color: Color(0xFFFCC83D), size: 24),
                SizedBox(width: 12),
                Text(
                  'Goodness starts with Dhikr Allah',
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _FeatureActions(),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      icon: Icon(icon, color: Colors.white, size: 28),
      splashRadius: 20,
    );
  }
}

class _FeatureActions extends StatelessWidget {
  const _FeatureActions();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _ActionCircle(
            icon: Icons.mosque_outlined,
            label: 'الروضة',
            selected: true,
          ),
          SizedBox(width: 18),
          _ActionCircle(
            icon: Icons.hexagon_outlined,
            label: 'الحج',
          ),
          SizedBox(width: 18),
          _ActionCircle(
            icon: Icons.brightness_2_outlined,
            label: 'العمرة',
          ),
          SizedBox(width: 18),
          _AlertCircle(),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(selected ? 26 : 36),
            borderRadius: BorderRadius.circular(33),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Icon(icon, size: 56, color: Colors.black.withAlpha(209)),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'Amiri'),
        ),
      ],
    );
  }
}

class _AlertCircle extends StatelessWidget {
  const _AlertCircle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            color: Color(0xFFEB4548),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 55),
      ],
    );
  }
}

class _QuranCard extends StatelessWidget {
  const _QuranCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Container(
            height: 560,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withAlpha(107),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_outlined, color: Color(0xFF2565EB), size: 38),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'القرآن الكريم',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Color(0xFF1F2938),
                      fontSize: 56,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                const Center(
                  child: Text(
                    'Al-Fatiha • Verse 1 • Page 1',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 20),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    width: 360,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8EB),
                      borderRadius: BorderRadius.circular(44),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ابدا تلاوتك',
                          style: TextStyle(
                            fontSize: 44,
                            color: Color(0xFF1F2938),
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.arrow_forward, size: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'اكتشف المزيد',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 54,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text('Services', style: TextStyle(color: Color(0xFF6B7280), fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 105,
            child: Row(
              children: [
                _FilterChip(label: 'All', selected: true),
                const SizedBox(width: 14),
                _FilterChip(icon: Icons.nightlight_round),
                const SizedBox(width: 14),
                _FilterChip(icon: Icons.wallet_membership_outlined),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: const [
                    _ServiceTile(icon: Icons.explore_outlined, label: 'استكشاف'),
                    SizedBox(height: 16),
                    _ServiceTile(icon: Icons.bed_outlined, label: 'الفنادق'),
                    SizedBox(height: 16),
                    _ServiceTile(icon: Icons.spa_outlined, label: 'السبحة'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: const [
                    _ServiceTile(icon: Icons.menu_book_outlined, label: 'الصلاة'),
                    SizedBox(height: 16),
                    _ServiceTile(icon: Icons.restaurant_outlined, label: 'المطاعم'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _TallFlightCard(),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      width: 102,
      height: 102,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: selected ? const Color(0xFF1D2C44) : const Color(0xFFF5F5F6),
      ),
      child: Center(
        child: label != null
            ? Text(label!, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 18))
            : Icon(icon, size: 36, color: const Color(0xFF121826)),
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
      height: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF0F1F4),
            ),
            child: Icon(icon, size: 38),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 32,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 366,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3E7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('New', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.center,
            child: Icon(Icons.flight_outlined, color: Color(0xFF3F83F8), size: 72),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'الطيران',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 48,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w700,
              ),
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
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFD8F0E7),
                ),
                child: const Icon(Icons.train_outlined, size: 42, color: Color(0xFF059669)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Popular', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'قطار الحرمين',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 52,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            top: BorderSide(color: Color(0xFF10B981), width: 6),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_outlined, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text(
                  'Try Nusuk AI',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Help me plan my upcoming journey.',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF1D2C44),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.black, width: 3),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Row(
              children: [
                Text(
                  'Ask and plan your journey',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Spacer(),
                Icon(Icons.arrow_forward, color: Colors.white, size: 34),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
