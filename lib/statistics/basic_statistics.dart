import 'package:flutter/material.dart';

class BasicStatisticsPage extends StatelessWidget {
  const BasicStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('카테고리별 수입', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: Placeholder()),
        SizedBox(height: 24),
        Text('카테고리별 지출', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: Placeholder()),
      ],
    );
  }
}