import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'layout/navigation.dart';
import 'login/login_home.dart';
import 'style/main_style.dart';
import 'group/post_add.dart';
import 'note/note_add.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      debugShowCheckedModeBanner: false,
      home: LoginHome(),

      onGenerateRoute: (settings) {
        if (settings.name == '/group/add') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => GroupPostAddScreen(existingPost: args),
          );
        }
        if (settings.name == '/note/add') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => QuickAddScreen(existingNote: args),
          );
        }
        return null; // 없는 라우트 처리
      },
    );
  }
}
