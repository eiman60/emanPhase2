import 'package:flutter/material.dart';
import '../Personal-Hajj-E-guide/map_screen.dart';
import '../Personal-Hajj-E-guide/location_service.dart';


class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              leading: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF3B33B),
                  child:
                      Icon(Icons.person_outline, size: 25, color: Colors.white),
                ),
              ),
              actions: const [
                Icon(Icons.wallet_outlined, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.notifications_outlined,
                    size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.more_vert, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 15),
              ],
              centerTitle: true,
              title: const Text(
                'استكشاف',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              14,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SearchBar(),
                SizedBox(height: 18),
                _SectionTitle(title: 'مناسك الحج بالترتيب', actionText: '⋯'),
                SizedBox(height: 10),
                _TripTimelineCard(),
                SizedBox(height: 18),
                _SectionTitle(title: 'الفئات', actionText: 'عرض الكل'),
                SizedBox(height: 10),
                _CategoriesRow(),
                SizedBox(height: 18),
                _SectionTitle(title: 'الرائج الآن'),
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
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Icon(Icons.search, size: 21, color: Color(0xFF8F9092)),
          SizedBox(width: 8),
          Text(
            'ابحث...',
            style: TextStyle(color: Color(0xFF9DA0A4), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionText});

  //final Color dotColor;
  final String title;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
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

class _TripTimelineCard extends StatefulWidget {
  const _TripTimelineCard();

  @override
  State<_TripTimelineCard> createState() => _TripTimelineCardState();
}

class _TripTimelineCardState extends State<_TripTimelineCard> {
  final LocationService _locationService = LocationService();
  String _currentZone = 'جاري تحديد الموقع...';
  bool _isLoading = true;

  static const List<String> _hajjOrder = [
    'منى',
    'عرفات',
    'مزدلفة',
    'الحرم المكي',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentZone();
  }

  Future<void> _loadCurrentZone() async {
    setState(() {
      _isLoading = true;
    });

    final zone = await _locationService.checkUserZone();
    if (!mounted) return;

    setState(() {
      _currentZone = zone;
      _isLoading = false;
    });
  }

  Color _dotColorForStep(int stepIndex) {
    final currentIndex = _hajjOrder.indexOf(_currentZone);
    if (currentIndex == -1) return const Color(0xFFCACACA);
    if (stepIndex < currentIndex) return const Color(0xFF3BAF5D);
    if (stepIndex == currentIndex) return const Color(0xFFF2BE2E);
    return const Color(0xFFCACACA);
  }

  Future<void> _chooseLocationFromMap() async {
    final selectedZone = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (!mounted || selectedZone == null) return;
    await _loadCurrentZone();
  }

  Future<void> _clearManualSelection() async {
    LocationService.clearManualZoneOverride();
    await _loadCurrentZone();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _hajjOrder.length; i++) ...[
            _TimelineRow(
              dotColor: _dotColorForStep(i),
              title: _hajjOrder[i],
              isCurrent: _hajjOrder[i] == _currentZone,
            ),
            if (i != _hajjOrder.length - 1) const SizedBox(height: 13),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isLoading ? 'جاري تحديث حالتك...' : 'موقعك الحالي: $_currentZone',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadCurrentZone,
                icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF545454)),
                tooltip: 'تحديث الموقع',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _chooseLocationFromMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('اختيار الموقع من الخريطة'),
                ),
              ),
              if (LocationService.manualZoneOverride != null)
                TextButton.icon(
                  onPressed: _clearManualSelection,
                  icon: const Icon(Icons.gps_fixed, size: 18),
                  label: const Text('العودة للموقع الحقيقي'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dotColor,
    required this.title,
    this.isCurrent = false,
  });

  final Color dotColor;
  final String title;
  final bool isCurrent;

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
              Text(
                isCurrent ? 'المحطة الحالية' : 'قيد المتابعة',
                style: TextStyle(
                  color: isCurrent ? const Color(0xFF1D1D1D) : const Color(0xFF7A7A7A),
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        isCurrent
            ? const Icon(
                Icons.my_location,
                color: Color(0xFFF2BE2E),
                size: 20,
              )
            : const SizedBox(width: 20, height: 20),
      ],
    );
  }
}

class _CategoriesRow extends StatefulWidget {
  const _CategoriesRow();

  @override
  State<_CategoriesRow> createState() => _CategoriesRowState();
}

class _CategoriesRowState extends State<_CategoriesRow> {
  int _selectedIndex = 0;

  static const List<_ExploreCategoryItem> _categories = [
    _ExploreCategoryItem(
      label: 'الصحة',
      icon: Icons.favorite_border,
      cards: [
        _CategoryCardData(
          imageAssetPath: 'assets/icons/healthy_1.png',
          title: 'مستشفى الطوارئ',
          subtitle: 'خدمات إسعافية على مدار الساعة',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/healthy_2.png',
          title: 'المستشفى السعودي الألماني',
          subtitle: 'رعاية طبية وتخصصات متعددة',
        ),
      ],
    ),
    _ExploreCategoryItem(
      label: 'انشطة',
      icon: Icons.local_activity_outlined,
      cards: [
        _CategoryCardData(
          imageAssetPath: 'assets/icons/active_1.png',
          title: 'غار ثور الثقافي',
          subtitle: 'نشاط ترفيهي',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/active_2.png',
          title: 'حديقه الملك فهد',
          subtitle: 'نزهة و تسوق',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/active_3.png',
          title: 'حي حراء الثقافي',
          subtitle: 'فعالية مناسبة للعائلة',
        ),
      ],
    ),
    _ExploreCategoryItem(
      label: 'المتاحف',
      icon: Icons.museum_outlined,
      cards: [
        _CategoryCardData(
          imageAssetPath: 'assets/icons/mus_1.png',
          title: 'معرض السيرة النبوية',
          subtitle: 'متحف بتاريخ إسلامي',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/mus_2.png',
          title: 'معرض الوحي',
          subtitle: 'معروضات من التراث المحلي',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/mus_3.png',
          title: 'متحف برج الساعة',
          subtitle: 'جولة معرفية مميزة',
        ),
      ],
    ),
    _ExploreCategoryItem(
      label: 'مأكولات',
      icon: Icons.restaurant_outlined,
      cards: [
        _CategoryCardData(
          imageAssetPath: 'assets/icons/food_1.png',
          title: 'مطعم سولت',
          subtitle: 'وجبات متنوعة بجودة عالية',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/food_2.png',
          title: 'ارتشي',
          subtitle: 'قهوة و حلويات',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/food_3.png',
          title: 'خطوة جمل',
          subtitle: 'قهوة متنوعة ',
        ),
      ],
    ),
    _ExploreCategoryItem(
      label: 'التسوق',
      icon: Icons.shopping_bag_outlined,
      cards: [
        _CategoryCardData(
          imageAssetPath: 'assets/icons/shop_1.png',
          title: 'بن داود',
          subtitle: 'متجر تسوق اطعمة و هدايا',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/shop_2.png',
          title: 'ابراج هايبر ماركن',
          subtitle: 'عروض يومية وأسعار مناسبة',
        ),
        _CategoryCardData(
          imageAssetPath: 'assets/icons/shop_3.png',
          title: 'بنده',
          subtitle: 'منتجات متنوعة بالقرب منك',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categories[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = index == _selectedIndex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 78,
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3E2723)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: const Color(0xFFD8D6D1),
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF404040),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF252525),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:
                selectedCategory.cards?.length ?? _CategoryCardData.fallback.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _CategoryImageCard(
              categoryLabel: selectedCategory.label,
              cardData:
                  selectedCategory.cards?[index] ??
                  _CategoryCardData.fallback[index],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreCategoryItem {
  const _ExploreCategoryItem({
    required this.label,
    required this.icon,
    this.cards,
  });

  final String label;
  final IconData icon;
  final List<_CategoryCardData>? cards;
}

class _CategoryCardData {
  const _CategoryCardData({
    required this.imageAssetPath,
    required this.title,
    required this.subtitle,
  });

  final String imageAssetPath;
  final String title;
  final String subtitle;

  static const List<_CategoryCardData> fallback = [
    _CategoryCardData(
      imageAssetPath: 'assets/icons/image_4.png',
      title: 'مكان الصورة',
      subtitle: 'وصف موجز للمكان',
    ),
    _CategoryCardData(
      imageAssetPath: 'assets/icons/image_5.png',
      title: 'مكان الصورة',
      subtitle: 'وصف موجز للمكان',
    ),
    _CategoryCardData(
      imageAssetPath: 'assets/icons/image_6.png',
      title: 'مكان الصورة',
      subtitle: 'وصف موجز للمكان',
    ),
  ];
}

class _CategoryImageCard extends StatelessWidget {
  const _CategoryImageCard({
    required this.categoryLabel,
    required this.cardData,
  });

  final String categoryLabel;
  final _CategoryCardData cardData;

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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(cardData.imageAssetPath, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F5F5F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardData.title,
                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cardData.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF656565),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _LocationsRow extends StatelessWidget {
  const _LocationsRow();

  @override
  Widget build(BuildContext context) {
    const locations = [
      ('منى', Icons.place_outlined),
      ('عرفات', Icons.place_outlined),
      ('مزدلفة', Icons.place_outlined),
      ('مكة المكرمة', Icons.place_outlined),
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'أنت الآن في: مكة المكرمة',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF353535),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2BE2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'تحديث الموقع',
                  style: TextStyle(
                    color: Color(0xFF2E2303),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'فتح الخريطه',
                    style: TextStyle(
                      color: Color(0xFF373737),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final location = locations[index];

              return Container(
                width: 130,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2BE2E).withAlpha(28),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        location.$2,
                        color: Color(0xFF9E6F08),
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      location.$1,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF202020),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrendingList extends StatelessWidget {
  const _TrendingList();

  static const List<_TrendingCardData> _trendCards = [
    _TrendingCardData(
      imageAssetPath: 'assets/icons/active_1.png',
      title: 'غار ثور الثقافي',
      subtitle: '4.9 (120 تقييمًا)',
      tag: 'الرائج الآن',
    ),
    _TrendingCardData(
      imageAssetPath: 'assets/icons/active_3.png',
      title: 'حي حراء الثقافي',
      subtitle: '4.8 (96 تقييمًا)',
      tag: 'الرائج الآن',
    ),
    _TrendingCardData(
      imageAssetPath: 'assets/icons/food_1.png',
      title: 'مطعم سولت',
      subtitle: '4.7 (88 تقييمًا)',
      tag: 'الرائج الآن',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _trendCards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _TrendingCard(cardData: _trendCards[index]),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.cardData});

  final _TrendingCardData cardData;

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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(cardData.imageAssetPath, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F5F5F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cardData.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardData.title,
                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_border,
                      size: 15,
                      color: Color(0xFFF2BE2E),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      cardData.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7D7D7D),
                        fontSize: 13,
                      ),
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

class _TrendingCardData {
  const _TrendingCardData({
    required this.imageAssetPath,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  final String imageAssetPath;
  final String title;
  final String subtitle;
  final String tag;
}
