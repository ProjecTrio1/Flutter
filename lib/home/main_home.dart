import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../style/main_style.dart';
import '../style/note_style.dart';
import 'widget/budget_card.dart';

class MenuHomeScreen extends StatefulWidget {
  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  int totalIncome = 0;
  int totalExpense = 0;
  int plannedIncome = 0;
  int plannedExpense = 0;

  List<Map<String, dynamic>> _top3Expenses = [];

  @override
  void initState() {
    super.initState();
    _loadPlannedValues();
    _fetchHomeNotes();
  }

  String _formatCurrency(int number) {
    return NumberFormat('#,###').format(number);
  }

  Future<void> _loadPlannedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      plannedIncome = prefs.getInt('plannedIncome') ?? 0;
      plannedExpense = prefs.getInt('plannedExpense') ?? 0;
    });
  }

  Future<void> _fetchHomeNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    if (userID == null) return;

    final url = Uri.parse('${AppConfig.baseUrl}/note/list?userID=$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final notes = jsonDecode(utf8.decode(response.bodyBytes));
      int income = 0;
      int expense = 0;
      List<Map<String, dynamic>> expensesOnly = [];

      for (var note in notes) {
        final date = DateTime.parse(note['createdAt']).toLocal();
        if (date.year == selectedYear && date.month == selectedMonth) {
          final amount = int.tryParse(note['amount'].toString()) ?? 0;
          final isIncome = note['isIncome'] == true;

          if (isIncome) {
            income += amount;
          } else {
            expense += amount;
            expensesOnly.add(note);
          }
        }
      }

      expensesOnly.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
      final top3 = expensesOnly.take(3).toList();

      setState(() {
        totalIncome = income;
        totalExpense = expense;
        _top3Expenses = top3;
      });
    }
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
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: () => setStateDialog(() => tempYear--),
                        ),
                        Text('$tempYear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () => setStateDialog(() => tempYear++),
                        ),
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
                            _fetchHomeNotes();
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


  void _showBudgetSettingDialog() {
    final incomeController = TextEditingController(text: plannedIncome.toString());
    final expenseController = TextEditingController(text: plannedExpense.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('예산/예정 수입 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: expenseController,
              decoration: InputDecoration(labelText: '예산 (총 지출)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: incomeController,
              decoration: InputDecoration(labelText: '예정 수입'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final newIncome = int.tryParse(incomeController.text) ?? plannedIncome;
              final newExpense = int.tryParse(expenseController.text) ?? plannedExpense;

              await prefs.setInt('plannedIncome', newIncome);
              await prefs.setInt('plannedExpense', newExpense);

              setState(() {
                plannedIncome = newIncome;
                plannedExpense = newExpense;
              });

              Navigator.pop(context);
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentUsed = plannedExpense > 0
        ? (totalExpense / plannedExpense * 100).clamp(0, 999).toInt()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showMonthSelector,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.textPrimary),
                SizedBox(width: 6),
                Text('$selectedYear년 $selectedMonth월', style: AppTextStyles.title),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: NoteDecorations.summaryBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('자산', style: AppTextStyles.title.copyWith(fontSize: 18)),
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_formatCurrency(totalIncome - totalExpense)}원',
                    style: AppTextStyles.bold.copyWith(fontSize: 28),
                  ),
                ),
                SizedBox(height: 16),
                if (plannedExpense > 0) ...[
                  Text('지출 목표 달성률', style: AppTextStyles.body.copyWith(fontSize: 13)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (percentUsed / 100).clamp(0.0, 1.0),
                    color: percentUsed <= 50
                        ? AppColors.incomeBlue
                        : percentUsed <= 80
                        ? Colors.purple
                        : AppColors.expenseRed,
                    backgroundColor: AppColors.surface,
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      percentUsed >= 100 ? '예산 초과!' : '$percentUsed% 사용 중',
                      style: NoteTextStyles.subtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('', style: AppTextStyles.title),
              IconButton(
                icon: Icon(Icons.settings, size: 20),
                onPressed: _showBudgetSettingDialog,
              ),
            ],
          ),
          BudgetCard(
            title: '총 지출',
            value: '${_formatCurrency(totalExpense)}원',
            sub: '예산 ${_formatCurrency(plannedExpense)}원',
            backgroundColor: AppColors.expenseRed,
          ),
          SizedBox(height: 12),
          BudgetCard(
            title: '총 수입',
            value: '${_formatCurrency(totalIncome)}원',
            sub: '예정 ${_formatCurrency(plannedIncome)}원',
            backgroundColor: AppColors.incomeBlue,
          ),
          SizedBox(height: 30),
          if (_top3Expenses.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(' 이번달 큰 지출!', style: AppTextStyles.title,),
                ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: NoteDecorations.summaryBox,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._top3Expenses.map((note) {
                    final content = note['content'] ?? '';
                    final amount = _formatCurrency(note['amount'] ?? 0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(content, style: AppTextStyles.body)),
                          Text('-$amount원', style: NoteTextStyles.expense),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
