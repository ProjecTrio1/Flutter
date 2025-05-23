import 'package:flutter/material.dart';
import '../../config.dart';
import '../../style/main_style.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.buttonText.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.body.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
