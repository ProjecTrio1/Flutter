import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final Color backgroundColor;

  const BudgetCard({
    super.key,
    required this.title,
    required this.value,
    required this.sub,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
