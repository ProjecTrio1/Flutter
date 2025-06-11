import 'package:flutter/material.dart';
import 'main_style.dart';

class InventoryTextStyles {
  static const TextStyle subHeader = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'SpoqaHanSansNeo',
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

class InventoryDecorations {
  static final BoxDecoration inputBox = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.borderGray),
    borderRadius: BorderRadius.circular(10),
  );

  static final ButtonStyle filledButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(48),
    textStyle: const TextStyle(
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    minimumSize: const Size(double.infinity, 48),
    textStyle: const TextStyle(
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle outlinedIconButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    backgroundColor: Colors.white,
    side: const BorderSide(color: AppColors.primary),
    textStyle: const TextStyle(
      fontFamily: 'SpoqaHanSansNeo',
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
    minimumSize: const Size(0, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
