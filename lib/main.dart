import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'layout/navigation.dart';
import 'login/login_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      home: LoginHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
