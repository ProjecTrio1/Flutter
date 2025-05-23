import 'package:flutter/material.dart';
import '../config.dart';

class AppColors {
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF0F5FB);
  static const Color primary = Color(0xFFFF7A00);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF888888);
  static const Color incomeBlue = Color(0xFF4A90E2);
  static const Color expenseRed = Color(0xFFFF5A5F);
  static const Color borderGray = Color(0xFFDDDDDD);
}

class AppTextStyles {
  static const TextStyle body = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    fontFamily: 'SpoqaHanSansNeo',
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.incomeBlue,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: AppTextStyles.title,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.white),
      trackColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.5)),
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.body,
    ),
  );
}
