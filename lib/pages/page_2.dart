import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../widgets/top_bar.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 14),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF3B33B),
              child: Icon(Icons.person_outline, size: 25, color: Colors.white),
            ),
          ),
          actions: const [
            TopIcon(iconPath: AppIcons.wallet, size: 25),
            SizedBox(width: 8),
            TopIcon(iconPath: AppIcons.notification, size: 25),
            SizedBox(width: 8),
            TopIcon(iconPath: AppIcons.menu, size: 25),
            SizedBox(width: 15),
          ],
          centerTitle: true,
          title: const Text(
            'Discover',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF2F1ED),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SearchBar(),
                SizedBox(height: 18),
                _SectionTitle(title: 'Trip Timeline', actionText: '⋯'),
                SizedBox(height: 10),
                _TripTimelineCard(),
                SizedBox(height: 18),
                _SectionTitle(title: 'Categories', actionText: 'See all'),
                SizedBox(height: 10),
                _CategoriesRow(),
                SizedBox(height: 18),
                _SectionTitle(title: 'Trending Now'),
                SizedBox(height: 10),
                _TrendingList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Icon(Icons.search, size: 21, color: Color(0xFF8F9092)),
          SizedBox(width: 8),
          Text(
            'Search ...',
            style: TextStyle(color: Color(0xFF9DA0A4), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionText});

  final Color dotColor;
  final String title;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
        const Spacer(),
        if (actionText != null)
          Text(
            actionText!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF545454),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _TripTimelineCard extends StatelessWidget {
  const _TripTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: const [
          _TimelineRow(
            dotColor: Color(0xFFCACACA),
            title: 'Start Journey',
          ),
          SizedBox(height: 13),
          _TimelineRow(
            dotColor: Color(0xFFF2BE2E),
            title: 'Return Journey',
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required Color dotColor, required this.title})
      : dotColor = dotColor;

  final Color dotColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF868686), fontSize: 13),
              ),
              const SizedBox(height: 2),
              const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xFF1D1D1D),
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Add',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('Health', Icons.favorite_border, Color(0xFF261613)),
      ('Family', Icons.family_restroom_outlined, Color(0xFFD8D6D1)),
      ('Adventure', Icons.terrain_outlined, Color(0xFFD8D6D1)),
      ('Relaxation', Icons.coffee_outlined, Color(0xFFD8D6D1)),
    ];

    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == 0;

          return SizedBox(
            width: 78,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.$3,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    category.$2,
                    color: isSelected ? Colors.white : const Color(0xFF404040),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF252525),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrendingList extends StatelessWidget {
  const _TrendingList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => const _TrendingCard(),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFCCCCCC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5F5F5F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Health & Wellness',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Bali Wellness Retreat',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_border, size: 15, color: Color(0xFFF2BE2E)),
                    SizedBox(width: 3),
                    Text(
                      '4.9 (120 reviews)',
                      style: TextStyle(color: Color(0xFF7D7D7D), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
