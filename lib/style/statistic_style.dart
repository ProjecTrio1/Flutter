import 'package:flutter/material.dart';

class StatisticColors {
  static const income = Color(0xFF4A90E2);
  static const expense = Color(0xFFFF5A5F);
  static const surface = Color(0xFFF9F9F9);

  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const subtitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const percent = TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54);
  static const highlightRed = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
  static const highlightBlue = TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
}

class StatisticStyles {
  static BoxDecoration get container => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
  );

  static final pieText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: Color(0xFFFF7A00), // AppColors.primary
    foregroundColor: Colors.white,
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static final highlightBox = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.orange, width: 1.5),
    borderRadius: BorderRadius.circular(8),
  );
}
