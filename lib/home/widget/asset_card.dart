import 'package:flutter/material.dart';
import '../../style/main_style.dart';

class AssetCard extends StatelessWidget {
  final int totalAsset;
  final String Function(int) formatCurrency;

  const AssetCard({
    super.key,
    required this.totalAsset,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('자산', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            '${formatCurrency(totalAsset)}원',
            style: AppTextStyles.bold.copyWith(fontSize: 26),
          ),
        ],
      ),
    );
  }
}
