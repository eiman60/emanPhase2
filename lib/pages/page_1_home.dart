import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../app_icons.dart';
import 'emergency_report_page.dart';

const double _homeSectionHeight = 280;
const double _homeSectionCornerRadius = 14;
const double _dhikrCardsViewportHeight = 296;
const EdgeInsets _dhikrCardItemPadding = EdgeInsets.fromLTRB(8, 6, 8, 6);

class Page1Home extends StatelessWidget {
  const Page1Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // AppBar سيكون شفافاً ويأخذ لون الخلفية
        appBar: AppBar(
          backgroundColor: Colors.transparent, // شفاف
          elevation: 0, // بدون ظل
          leading: const Padding(
            padding: EdgeInsets.only(left: 14),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF3B33B),
              child: Icon(Icons.person_outline, size: 25, color: Colors.white),
            ),
          ),
          actions: const [
            Icon(Icons.wallet_outlined, size: 25, color: Color(0xFFEDEDED)),
            SizedBox(width: 8),
            Icon(Icons.notifications_outlined,
                size: 25, color: Color(0xFFEDEDED)),
            SizedBox(width: 8),
            Icon(Icons.more_vert, size: 25, color: Color(0xFFEDEDED)),
            SizedBox(width: 15),
          ],

          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5C4033),
                Color(0xFF3E2723),
                Color(0xFF3E2723),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom +
                  kBottomNavigationBarHeight +
                  20,
            ),
            child: Column(
              children: [
                const _HeroSection(),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: const Column(
                    children: [
                      _DhikrSectionsContainer(),
                      SizedBox(height: 24),
                    ],
                  ),
                )
              ],
            ),
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
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: [
          SizedBox(height: topInset + kToolbarHeight),
          const _PrayerFocus(),
          const SizedBox(height: 18),
          const _FeatureActions(),
        ],
      ),
    );
  }
}

class _PrayerFocus extends StatelessWidget {
  const _PrayerFocus();

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
          intl.DateFormat('hh:mm:ss a', 'ar').format(now),
        );

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
              child: const Center(
                  child: AssetIconView(assetPath: AppIcons.hajj, size: 34)),
            ),
            const SizedBox(height: 12),
            Text(dateText,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
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
                  Icon(Icons.access_time, color: Color(0xFFFCC83D), size: 16),
                  SizedBox(width: 6),
                  Text('الوقت الحالي',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureActions extends StatelessWidget {
  const _FeatureActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 14,
      children: [
        const _ActionCircle(
            iconPath: AppIcons.rawdah, label: 'الروضة', selected: true),
        const _ActionCircle(iconPath: AppIcons.hajj, label: 'الحج'),
        const _ActionCircle(iconPath: AppIcons.umrah, label: 'العمره'),
        const _AlertCircle(),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle(
      {required this.iconPath, required this.label, this.selected = false});

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
            color: selected
                ? Colors.white.withAlpha(18)
                : Colors.white.withAlpha(10),
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
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Almarai', fontSize: 12)),
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
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text(
              'الطوارئ',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontFamily: 'Almarai', fontWeight: FontWeight.w700),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إذا كنت بحاجة إلى المساعدة الفورية، يمكنك إرسال بلاغ طارئ الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Almarai', height: 1.5),
              ),
              const SizedBox(height: 14),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('إغلاق',
                          style:
                              TextStyle(fontFamily: 'Almarai', fontSize: 12)),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _openEmergencyReportPage(context);
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEB4548)),
                      child: const Text('الإبلاغ عن حالة طارئة',
                          style:
                              TextStyle(fontFamily: 'Almarai', fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                child: Icon(
                  Icons.emergency_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('الطوارئ',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Almarai', fontSize: 12)),
      ],
    );
  }
}

class _PrayerTimesCard extends StatelessWidget {
  const _PrayerTimesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_homeSectionCornerRadius),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrayerTimeColumn(
              icon: Icons.wb_twilight,
              label: 'الفجر',
              time: '05:18',
            ),
            _PrayerTimeColumn(
              icon: Icons.wb_sunny_outlined,
              label: 'الظهر',
              time: '12:25',
            ),
            _PrayerTimeColumn(
              icon: Icons.wb_sunny_outlined,
              label: 'العصر',
              time: '15:48',
            ),
            _PrayerTimeColumn(
              icon: Icons.wb_twilight,
              label: 'المغرب',
              time: '18:32',
              flipIconVertically: true,
            ),
            _PrayerTimeColumn(
              icon: Icons.nightlight_outlined,
              label: 'العشاء',
              time: '19:55',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimeColumn extends StatelessWidget {
  const _PrayerTimeColumn({
    required this.icon,
    required this.label,
    required this.time,
    this.flipIconVertically = false,
  });

  final IconData icon;
  final String label;
  final String time;
  final bool flipIconVertically;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8A6A4E);
    Widget iconWidget = Icon(icon, size: 28, color: accent);
    if (flipIconVertically) {
      iconWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(1.0, -1.0),
        child: iconWidget,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: accent,
            fontSize: 10,
            fontFamily: 'Almarai',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _QuranCard extends StatelessWidget {
  const _QuranCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 252,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_homeSectionCornerRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    child: Image.asset(
                      'assets/icons/fatiha_bitmap.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          'Add assets/icons/fatiha_bitmap.png',
                          style:
                              TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xCCFFFFFF),
                            Color(0xFFFFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 176,
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFFF8F6F0),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ابدا تلاوتك',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1F2938),
                    fontFamily: 'Almarai',
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
    );
  }
}

class _DhikrSection extends StatefulWidget {
  const _DhikrSection();

  @override
  State<_DhikrSection> createState() => _DhikrSectionState();
}

class _DhikrSectionState extends State<_DhikrSection> {
  int _activeIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_activeIndex < _dhikrCards.length - 1) {
      _pageController.animateToPage(
        _activeIndex + 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goPrevious() {
    if (_activeIndex > 0) {
      _pageController.animateToPage(
        _activeIndex - 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          SizedBox(
            height: _dhikrCardsViewportHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _dhikrCards.length,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (context, i) => Padding(
                padding: _dhikrCardItemPadding,
                child: _DhikrCard(
                  data: _dhikrCards[i],
                  expanded: true,
                  onTap: () {
                    if (i > _activeIndex) {
                      _goNext();
                    } else if (i < _activeIndex) {
                      _goPrevious();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _dhikrCards.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _activeIndex ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _activeIndex
                      ? const Color(0xFF6F4E37)
                      : const Color(0xFFD9D4C8),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrSectionsContainer extends StatelessWidget {
  const _DhikrSectionsContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_homeSectionCornerRadius),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Column(
        children: [
          _PrayerTimesCard(),
          SizedBox(height: 12),
          _QuranCard(),
          SizedBox(height: 16),
          _DhikrSection(),
          SizedBox(height: 16),
          _CustomDhikrSection(),
        ],
      ),
    );
  }
}

class _CustomDhikrSection extends StatefulWidget {
  const _CustomDhikrSection();

  @override
  State<_CustomDhikrSection> createState() => _CustomDhikrSectionState();
}

class _CustomDhikrSectionState extends State<_CustomDhikrSection> {
  final List<_DhikrCardData> _customCards = [];
  late final PageController _customPageController;
  late final TextEditingController _dhikrTitleController;
  late final TextEditingController _dhikrContentController;
  int _customActiveIndex = 0;

  @override
  void initState() {
    super.initState();
    _customPageController = PageController();
    _dhikrTitleController = TextEditingController();
    _dhikrContentController = TextEditingController();
  }

  @override
  void dispose() {
    _customPageController.dispose();
    _dhikrTitleController.dispose();
    _dhikrContentController.dispose();
    super.dispose();
  }

  void _deleteActiveCard() {
    if (_customCards.isEmpty) {
      return;
    }

    setState(() {
      _customCards.removeAt(_customActiveIndex);
      if (_customCards.isEmpty) {
        _customActiveIndex = 0;
      } else if (_customActiveIndex >= _customCards.length) {
        _customActiveIndex = _customCards.length - 1;
      }
    });

  }

  Future<void> _showCreateDialog() async {
    _dhikrTitleController.clear();
    _dhikrContentController.clear();

    final createdCard = await showDialog<_DhikrCardData>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'إضافة ذكر جديد',
            style:
                TextStyle(color: Color(0xFF8A6A4E), fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _dhikrTitleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      hintText: 'مثال: ذكر بعد الصلاة',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dhikrContentController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'المحتوى',
                      hintText: 'اكتب الذكر هنا...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8A6A4E),
              ),
              onPressed: () {
                final title = _dhikrTitleController.text.trim();
                final content = _dhikrContentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(
                  _DhikrCardData(
                    title: title,
                    color: const Color(0xFFF3B33B),
                    content: content,
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || createdCard == null) {
      return;
    }

    setState(() {
      _customCards.add(createdCard);
      if (_customCards.length == 1) {
        _customActiveIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_customCards.isNotEmpty) ...[
          SizedBox(
            height: 340,
            child: _buildCardsArea(),
          ),
          const SizedBox(height: 6),
        ],
        FilledButton(
          onPressed: _showCreateDialog,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF3B33B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          child: const Text(
            'اضف اذكارك',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsArea() {
    return Column(
      children: [
        SizedBox(
          height: _dhikrCardsViewportHeight,
          child: PageView.builder(
            controller: _customPageController,
            itemCount: _customCards.length,
            onPageChanged: (index) =>
                setState(() => _customActiveIndex = index),
            itemBuilder: (_, index) => Padding(
              padding: _dhikrCardItemPadding,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 450) {
                    _deleteActiveCard();
                  }
                },
                child: _DhikrCard(
                  data: _customCards[index],
                  expanded: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _customCards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == _customActiveIndex ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == _customActiveIndex
                    ? const Color(0xFF8A6A4E)
                    : const Color(0xFFD9D4C8),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DhikrCardData {
  const _DhikrCardData({
    required this.title,
    required this.color,
    required this.content,
  });

  final String title;
  final Color color;
  final String content;
}

const _dhikrCards = [
  _DhikrCardData(
    title: 'أذكار المساء',
    color: Color(0xFF6F4E37),
    content:
        'اللهم بك أمسينا وبك نحيا وبك نموت وإليك المصير.\nاللهم إني أسألك خير هذه الليلة وخير ما بعدها.',
  ),
  _DhikrCardData(
    title: 'دعاء السفر',
    color: Color(0xFF7C5A40),
    content:
        'سبحان الذي سخر لنا هذا وما كنا له مقرنين.\nاللهم هون علينا سفرنا هذا واطوِ عنا بُعده.',
  ),
  _DhikrCardData(
    title: 'دعاء النوم',
    color: Color(0xFF88644A),
    content:
        'باسمك اللهم أموت وأحيا.\nاللهم قني عذابك يوم تبعث عبادك، واجعل ليلتي سكينة وطمأنينة.',
  ),
  _DhikrCardData(
    title: 'دعاء الخروج',
    color: Color(0xFF957157),
    content:
        'بسم الله، توكلت على الله، لا حول ولا قوة إلا بالله.\nاللهم إني أعوذ بك أن أضل أو أُضل.',
  ),
  _DhikrCardData(
    title: 'دعاء ليلة القدر',
    color: Color(0xFFA27E65),
    content:
        'اللهم إنك عفوٌ كريمٌ تحب العفو فاعفُ عني.\nاللهم اجعل لنا من كل همٍ فرجًا ومن كل ضيقٍ مخرجًا.',
  ),
];

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.data,
    required this.expanded,
    required this.onTap,
  });

  final _DhikrCardData data;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardHeader = Align(
      alignment: Alignment.topRight,
      child: Text(
        data.title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFFF8F6F0),
          fontSize: 13,
          fontFamily: 'Almarai',
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );

    final cardContent = Text(
      data.content,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Color(0xFFF8F6F0),
        fontSize: 11,
        height: 1.65,
        fontFamily: 'Almarai',
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: expanded ? 280 : 86,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: expanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  cardHeader,
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: cardContent,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: cardHeader,
              ),
      ),
    );
  }
}
