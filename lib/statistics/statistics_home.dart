import 'package:flutter/material.dart';
import '../config.dart';
import 'basic_statistics.dart';
import 'inventory/inventory_home.dart';
import 'ai_analysis/ai_analysis_home.dart';
import '../style/statistic_style.dart';

class StatisticsHome extends StatefulWidget {
  const StatisticsHome({super.key});

  @override
  State<StatisticsHome> createState() => _StatisticsHomeState();
}

class _StatisticsHomeState extends State<StatisticsHome> {
  String selectedType = '수입';

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
          children: [
            Container(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['수입', '지출'].map((type) {
                  final isSelected = type == selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => selectedType = type);
                      },
                      selectedColor: isSelected
                          ? (type == '수입'
                          ? StatisticColors.income
                          : StatisticColors.expense)
                          : Colors.grey.shade300,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 핵심 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: StatisticStyles.buttonStyle,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryHomePage()));
                  },
                  child: const Text('모아보기'),
                ),
                ElevatedButton(
                  style: StatisticStyles.buttonStyle,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AIAnalysisHomePage()));
                  },
                  child: const Text('AI 분석'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 본문 통계
            BasicStatisticsPage(selectedType: selectedType),
          ],
        ),
      ),
    );
  }
}
