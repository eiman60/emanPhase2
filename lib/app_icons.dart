import 'package:flutter/material.dart';

/// Central place for all custom icon asset paths.
///
/// Put your downloaded icon files in `assets/icons/` and update names here.
class AppIcons {
  static const String user = 'assets/icons/user.png';
  static const String wallet = 'assets/icons/wallet.png';
  static const String notification = 'assets/icons/notification.png';
  static const String menu = 'assets/icons/menu.png';
  static const String cube = 'assets/icons/cube.png';
  static const String rawdah = 'assets/icons/rawdah.png';
  static const String hajj = 'assets/icons/hajj.png';
  static const String umrah = 'assets/icons/umrah.png';
  static const String alert = 'assets/icons/alert.png';
}

class AssetIconView extends StatelessWidget {
  const AssetIconView({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius,
  });

  final String assetPath;
  final double size;
  final Color iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final icon = Image.asset(
      assetPath,
      width: size,
      height: size,
      color: iconColor,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_outlined,
        size: size,
        color: iconColor,
      ),
    );

    if (backgroundColor == null) {
      return icon;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
      child: icon,
    );
  }
}
