import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/nusuk_home_page.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (_isKnownWebKeyboardInsetsError(message)) {
      debugPrint('Ignored Flutter web keyboard insets assertion: $message');
      return;
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    final message = error.toString();
    if (_isKnownWebKeyboardInsetsError(message)) {
      debugPrint('Ignored Flutter web keyboard insets assertion: $message');
      return true;
    }
    return false;
  };

  runApp(const NusukApp());
}

bool _isKnownWebKeyboardInsetsError(String message) {
  return kIsWeb &&
      message.contains('_viewInsets.isNonNegative') &&
      message.contains('ViewInsets cannot be negative');
}

class NusukApp extends StatelessWidget {
  const NusukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.almarai().fontFamily,
        textTheme: _compactAlmaraiTextTheme(),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const NusukHomePage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // تحديد اتجاه النصوص
          child: child!,
        );
      },
    );
  }
}

TextTheme _compactAlmaraiTextTheme() {
  final base = GoogleFonts.almaraiTextTheme(ThemeData.light().textTheme);
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontSize: 12),
    displayMedium: base.displayMedium?.copyWith(fontSize: 12),
    displaySmall: base.displaySmall?.copyWith(fontSize: 12),
    headlineLarge: base.headlineLarge?.copyWith(fontSize: 12),
    headlineMedium: base.headlineMedium?.copyWith(fontSize: 12),
    headlineSmall: base.headlineSmall?.copyWith(fontSize: 12),
    titleLarge: base.titleLarge?.copyWith(fontSize: 12),
    titleMedium: base.titleMedium?.copyWith(fontSize: 12),
    titleSmall: base.titleSmall?.copyWith(fontSize: 11),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 12),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 11),
    bodySmall: base.bodySmall?.copyWith(fontSize: 10),
    labelLarge: base.labelLarge?.copyWith(fontSize: 11),
    labelMedium: base.labelMedium?.copyWith(fontSize: 10),
    labelSmall: base.labelSmall?.copyWith(fontSize: 10),
  );
}
