import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layout/navigation.dart';
import 'login/login_home.dart';
import 'style/main_style.dart';
import 'group/post_add.dart';
import 'note/note_add.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userID = prefs.getInt('userID');

  runApp(MyApp(isLoggedIn: userID != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? Navigation() : LoginHome(),
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
        return null;
      },
    );
  }
}
