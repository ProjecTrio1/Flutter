import 'package:flutter/material.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('자산', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('${formatCurrency(totalAsset)}원',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildRow('어디은행', '103,012원'),
            _buildRow('어디은행', '103,012원'),
            _buildRow('카드결제대금', '-103,012원'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 14)),
          Text(amount, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
