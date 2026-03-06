import 'package:flutter/material.dart';

import '../app_icons.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF3B33B),
          child: Icon(Icons.person_outline, size: 20, color: Colors.white),
        ),
        SizedBox(width: 10),
        Spacer(),
        _TopIcon(iconPath: AppIcons.wallet, size: 19),
        SizedBox(width: 8),
        _TopIcon(iconPath: AppIcons.notification, size: 19),
        SizedBox(width: 8),
        _TopIcon(iconPath: AppIcons.menu, size: 19),
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
