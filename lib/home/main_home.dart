import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../note/note_add.dart';
import 'service/home_summary_api.dart';
import 'widget/budget_card.dart';
import 'widget/asset_card.dart';
import 'widget/year_month_picker.dart';

class MenuHomeScreen extends StatefulWidget {
  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  String selectedMonth = '3월';
  String selectedYear = '2024년';

  final List<String> months = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];
  final List<String> years = [
    '2024년', '2025년'
  ];

  int totalIncome = 0;
  int totalExpense = 0;

  String _formatCurrency(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  void _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => YearMonthPicker(
        years: years,
        months: months,
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        onYearSelected: (val) => setState(() => selectedYear = val),
        onMonthSelected: (val) => setState(() => selectedMonth = val),
      ),
    );
  }

  Future<void> _loadSummary() async {
    final result = await HomeSummaryService.fetchSummary(
      selectedYear.replaceAll('년', ''),
      selectedMonth.replaceAll('월', ''),
    );

    if (result != null) {
      setState(() {
        totalIncome = result['income']!;
        totalExpense = result['expense']!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showPicker,
            child: Row(
              children: [
                Text(
                  '$selectedYear $selectedMonth',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.expand_more),
              ],
            ),
          ),
          SizedBox(height: 16),
          BudgetCard(
            title: '총 지출',
            value: '${_formatCurrency(totalExpense)}원',
            sub: '예산 700,000원',
            backgroundColor: Color(0xFFFFA448),
          ),
          SizedBox(height: 12),
          BudgetCard(
            title: '총 수입',
            value: '${_formatCurrency(totalIncome)}원',
            sub: '예정 1,000,000원',
            backgroundColor: Color(0xFFFFA448),
          ),
          SizedBox(height: 16),
          AssetCard(
            totalAsset: totalIncome - totalExpense,
            formatCurrency: _formatCurrency,
          )
        ],
      ),
    );
  }
}