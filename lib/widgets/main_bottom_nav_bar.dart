import 'package:flutter/material.dart';

import '../app_icons.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(28),
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
