import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class YearMonthPicker extends StatelessWidget {
  final List<String> years;
  final List<String> months;
  final String selectedYear;
  final String selectedMonth;
  final void Function(String) onYearSelected;
  final void Function(String) onMonthSelected;

  const YearMonthPicker({
    super.key,
    required this.years,
    required this.months,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearSelected,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16, top: 8),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: years.indexOf(selectedYear),
                    ),
                    onSelectedItemChanged: (index) {
                      onYearSelected(years[index]);
                    },
                    children: years.map((y) => Center(child: Text(y))).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: months.indexOf(selectedMonth),
                    ),
                    onSelectedItemChanged: (index) {
                      onMonthSelected(months[index]);
                    },
                    children: months.map((m) => Center(child: Text(m))).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
