import 'package:flutter/material.dart';

class StatisticColors {
  static const colorPalette = [
  Color(0xFFFF0000),
  Color(0xFFFFA166),
  Color(0xFFFFEF60),
  Color(0xFFC5FF5E),
  Color(0xFF459C52),
  Color(0xFF98CDFF),
  Color(0xFF54AFFF),
  Color(0xFF335CFF),
  Color(0xFF796CFF),
  Color(0xFF822FFF),
  Color(0xFFF56CFF),
  Color(0xFFA8A8A8)
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
