import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../style/statistic_style.dart';

class BasicStatisticsPage extends StatefulWidget {
  final String selectedType;
  const BasicStatisticsPage({super.key, required this.selectedType});

  @override
  State<BasicStatisticsPage> createState() => _BasicStatisticsPageState();
}

class _BasicStatisticsPageState extends State<BasicStatisticsPage> {
  List<Map<String, dynamic>> _expenseData = [];
  List<Map<String, dynamic>> _incomeData = [];
  String increasedCategory = '';
  int increasedAmount = 0;
  double increasedRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStatisticsData();
  }

  Future<void> _fetchStatisticsData() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final response = await http.get(Uri.parse('http://10.0.2.2:8080/statistics?year=$year&month=$month'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _expenseData = List<Map<String, dynamic>>.from(decoded['expense']);
        _incomeData = List<Map<String, dynamic>>.from(decoded['income']);
        increasedCategory = decoded['maxIncreasedCategory'] ?? '';
        increasedAmount = decoded['maxIncreasedAmount'] ?? 0;
        increasedRate = decoded['maxIncreasedRate'] ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.selectedType == '지출';
    final currentData = isExpense ? _expenseData : _incomeData;
    final total = currentData.fold(0, (sum, e) => sum + (e['amount'] as int));
    final formatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.selectedType} 총합: ${formatter.format(total)}원', style: StatisticColors.title),
        const SizedBox(height: 12),

        if (isExpense && increasedCategory.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: StatisticStyles.highlightBox,
            child: RichText(
              text: TextSpan(
                text: '📢 ',
                style: StatisticColors.subtitle,
                children: [
                  TextSpan(text: '$increasedCategory', style: StatisticColors.highlightBlue),
                  const TextSpan(text: ' 카테고리 지출 증가\n'),
                  const TextSpan(text: '전월 대비 '),
                  TextSpan(
                    text: '${(increasedRate * 100).toStringAsFixed(1)}%',
                    style: StatisticColors.highlightRed,
                  ),
                  TextSpan(text: ' (${formatter.format(increasedAmount)}원) 증가'),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: currentData.map((e) {
                final percentage = total > 0 ? (e['amount'] / total * 100).toStringAsFixed(1) : '0.0';
                final color = isExpense ? StatisticColors.expense : StatisticColors.income;
                return PieChartSectionData(
                  value: (e['amount'] as int).toDouble(),
                  title: '$percentage%',
                  color: color.withOpacity(0.7),
                  radius: 60,
                  titleStyle: StatisticStyles.pieText,
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Column(
          children: currentData.map((e) {
            final rate = total > 0 ? (e['amount'] / total * 100).toStringAsFixed(1) : '0.0';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 12, height: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text('${e['category']}', style: StatisticColors.subtitle),
                    ],
                  ),
                  Text('${rate}%  ${formatter.format(e['amount'])}원', style: StatisticColors.percent),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
