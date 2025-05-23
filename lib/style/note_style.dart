import 'package:flutter/material.dart';
import '../config.dart';
import 'main_style.dart';

class NoteColors {
  static const Color income = AppColors.incomeBlue;
  static const Color expense = AppColors.expenseRed;
  static const Color surface = AppColors.surface;
  static const Color border = AppColors.borderGray;
}

class NoteTextStyles {
  static const TextStyle subHeader = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle income = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: NoteColors.income,
  );

  static const TextStyle expense = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: NoteColors.expense,
  );

  static const TextStyle total = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle time = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 12,
    color: AppColors.textSecondary,
  );

}

class NoteDecorations {
  static final BoxDecoration inputBox = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: NoteColors.border),
    borderRadius: BorderRadius.circular(10),
  );

  static final BoxDecoration card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.zero,
    border: Border(
      top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
      bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
    ),
  );

  static final BoxDecoration summaryBox = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(10),
  );

  static final ButtonStyle filledButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: Size(0, 48),
    textStyle: TextStyle(
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
    minimumSize: Size(double.infinity, 48),
    textStyle: TextStyle(
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );


}
