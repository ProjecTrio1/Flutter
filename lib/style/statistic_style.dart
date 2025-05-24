import 'package:flutter/material.dart';

class StatisticColors {
  static const colorPalette = [
  Color(0xFFCD5F5F),
  Color(0xFF36668A),
  Color(0xFF297327),
  Color(0xFF7A3C87),
  Color(0xFF7A552D),
  Color(0xFFFFD92F),
  Color(0xFFA65628),
  Color(0xFFF781BF),
  Color(0xFF999999),
  Color(0xFF66C2A5),
  Color(0xFFFC8D62),
  Color(0xFF8DA0CB)
  ];

  static const pieTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  static const categoryLabel = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const amount = TextStyle(fontSize: 17);
}

class StatisticStyles {
  static const dotSize = 14.0;

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
