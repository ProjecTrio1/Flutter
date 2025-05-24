import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../style/statistic_style.dart';
import '../style/note_style.dart';
import '../style/main_style.dart';
import 'inventory/inventory_home.dart';
import 'ai_analysis/ai_analysis_home.dart';

class StatisticsHome extends StatefulWidget {
  const StatisticsHome({super.key});

  @override
  State<StatisticsHome> createState() => _StatisticsHomeState();
}

class _StatisticsHomeState extends State<StatisticsHome> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int _totalIncome = 0;
  int _totalExpense = 0;
  List<Map<String, dynamic>> _expenseCategories = [];
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchNoteData();
  }

  Future<void> _fetchNoteData() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    if (userID == null) return;

    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/note/list?userID=$userID'));
    if (response.statusCode != 200) return;

    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final filtered = decoded.where((n) {
      final date = DateTime.parse(n['createdAt']).toLocal();
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    final incomeList = filtered.where((n) => n['isIncome'] == true);
    final expenseList = filtered.where((n) => n['isIncome'] == false);

    final incomeTotal = incomeList.fold<int>(0, (sum, n) => sum + (n['amount'] as num).toInt());
    final expenseTotal = expenseList.fold<int>(0, (sum, n) => sum + (n['amount'] as num).toInt());

    Map<String, int> expenseSum = {};
    for (final item in expenseList) {
      final cat = item['category'] ?? '기타';
      final amt = (item['amount'] as num).toInt();
      expenseSum[cat] = (expenseSum[cat] ?? 0) + amt;
    }

    final sortedExpenses = expenseSum.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _totalIncome = incomeTotal;
      _totalExpense = expenseTotal;
      _expenseCategories = sortedExpenses.map((e) => {
        'category': e.key,
        'amount': e.value
      }).toList();
    });
  }

  void _showMonthSelector() async {
    int tempYear = selectedYear;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: Icon(Icons.chevron_left), onPressed: () => setStateDialog(() => tempYear--)),
                        Text('$tempYear년', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: Icon(Icons.chevron_right), onPressed: () => setStateDialog(() => tempYear++)),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      children: List.generate(12, (i) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedYear = tempYear;
                              selectedMonth = i + 1;
                            });
                            _fetchNoteData();
                          },
                          child: Text('${i + 1}월'),
                        );
                      }),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showMonthSelector,
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20),
              SizedBox(width: 6),
              Text('$selectedYear년 $selectedMonth월'),
              Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIAnalysisHomePage())),
                icon: Icon(Icons.smart_toy, color: AppColors.primary),
                label: Text('AI 분석', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryHomePage())),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.inventory_2, color: Colors.white, size: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: NoteDecorations.summaryBox,
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('총수입', style: NoteTextStyles.total),
                    Text('${formatter.format(_totalIncome)}원', style: NoteTextStyles.income),
                  ]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('총지출', style: NoteTextStyles.total),
                    Text('${formatter.format(_totalExpense)}원', style: NoteTextStyles.expense),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ' 지출 통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sectionsSpace: 1,
                      sections: _expenseCategories.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final value = (e['amount'] as int).toDouble();
                        final percent = _totalExpense == 0 ? 0.0 : (value / _totalExpense) * 100;
                        return PieChartSectionData(
                          value: value,
                          color: StatisticColors.colorPalette[i % StatisticColors.colorPalette.length],
                          radius: i == _touchedIndex ? 110 : 100,
                          title: '',
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (response == null || response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_touchedIndex != -1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expenseCategories[_touchedIndex]['category'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${((_expenseCategories[_touchedIndex]['amount'] / _totalExpense) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: NoteDecorations.summaryBox,
              child: Column(
                children: _expenseCategories.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final percent = (_totalExpense == 0 ? 0 : (e['amount'] / _totalExpense) * 100).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: StatisticColors.colorPalette[i % StatisticColors.colorPalette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${e['category']}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$percent%',
                                style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${formatter.format(e['amount'])}원',
                          style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
