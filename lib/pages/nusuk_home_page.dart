import 'package:flutter/material.dart';

import '../widgets/main_bottom_nav_bar.dart';
import 'page_1_home.dart';
import 'page_2.dart';
import 'page_3_chat.dart';
import 'page_4.dart';
import 'page_5.dart';

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
    Widget page;
    if (_selectedIndex == 0) {
      page = const Page1Home();
    } else if (_selectedIndex == 1) {
      page = const Page2();
    } else if (_selectedIndex == 2) {
      page = Page3Chat(onBack: () => _onNavTap(0));
    } else if (_selectedIndex == 3) {
      page = const Page4();
    } else {
      page = const Page5();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      bottomNavigationBar: _selectedIndex == 2
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                height: 60,
                child: MainBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onTap: _onNavTap,
                ),
              ),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 375),
            child: page,
          ),
        ),
      ),
    );
  }
}
