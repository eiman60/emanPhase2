import 'package:flutter/material.dart';
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
  int currentIndex = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Page1Home(),
      const Page2(),
      Page3Chat(onBack: () => onTap(0)),
      const Page4(),
      const Page5(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15), // المسافة من جميع الأطراف
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25), // انحناء الأطراف
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  label: "home",
                  icon: Image.asset(
                    "assets/icons/image_2.png",
                    height: 20,
                  ),
                ),
                BottomNavigationBarItem(
                  label: "home2",
                  icon: Image.asset(
                    "assets/icons/image_2.png",
                    height: 20,
                  ),
                ),
                BottomNavigationBarItem(
                  label: "chat",
                  icon: Image.asset(
                    "assets/icons/image_15.png",
                    height: 20,
                  ),
                ),
                BottomNavigationBarItem(
                  label: "home3",
                  icon: Image.asset(
                    "assets/icons/image_9.png",
                    height: 20,
                  ),
                ),
                BottomNavigationBarItem(
                  label: "more",
                  icon: Image.asset(
                    "assets/icons/image_2.png",
                    height: 20,
                  ),
                ),
              ],
              type: BottomNavigationBarType.fixed,
              onTap: onTap,
              currentIndex: currentIndex,
              selectedItemColor: Colors.yellow,
              unselectedItemColor: Colors.black54,
              backgroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
