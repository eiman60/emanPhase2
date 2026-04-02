import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/nusuk_home_page.dart';

void main() {
  runApp(const NusukApp());
}

class NusukApp extends StatelessWidget {
  const NusukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
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
