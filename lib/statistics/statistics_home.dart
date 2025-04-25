import 'package:flutter/material.dart';
import 'basic_statistics.dart';
import 'inventory/inventory_home.dart';
import 'ai_analysis/ai_analysis_home.dart';

class StatisticsHome extends StatelessWidget {
  const StatisticsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicStatisticsPage(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InventoryHomePage()),
              ),
              child: Text('모아보기'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AIAnalysisHomePage()),
              ),
              child: Text('AI 분석'),
            ),
          ],
        ),
      ),
    );
  }
}