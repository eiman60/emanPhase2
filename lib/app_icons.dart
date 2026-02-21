import 'package:flutter/material.dart';

/// Central place for all custom icon asset paths.
///
/// Keep icon files inside `assets/icons/` (recommended) or `lib/icons/`.
/// This project currently uses the icon pack already stored in `lib/icons/`.
class AppIcons {
  static const String user = 'lib/icons/image_1.png';
  static const String wallet = 'lib/icons/image_11.png';
  static const String notification = 'lib/icons/image_13.png';
  static const String menu = 'lib/icons/image_14.png';
  static const String cube = 'lib/icons/image_5.png';
  static const String rawdah = 'lib/icons/image_7.png';
  static const String hajj = 'lib/icons/image_8.png';
  static const String umrah = 'lib/icons/image_9.png';
  static const String alert = 'lib/icons/image_17.png';
  static const String image2 = 'lib/icons/image_2.png';
  static const String image3 = 'lib/icons/image_3.png';
  static const String image12 = 'lib/icons/image_12.png';
  static const String image15 = 'lib/icons/image_15.png';
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
