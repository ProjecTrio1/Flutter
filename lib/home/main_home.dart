import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../note/note_add.dart';

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

  void _showCupertinoYearMonthPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
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
                        setState(() {
                          selectedYear = years[index];
                        });
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
                        setState(() {
                          selectedMonth = months[index];
                        });
                      },
                      children: months.map((m) => Center(child: Text(m))).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LOGO'),
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 12),
                Icon(Icons.menu, color: Colors.white),
              ],
            )
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월/년도 선택 버튼
            GestureDetector(
              onTap: _showCupertinoYearMonthPicker,
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

            _buildBudgetCard(
              title: '총 지출',
              value: '570,000원',
              sub: '예산 700,000원',
              backgroundColor: Color(0xFFFFA448),
            ),
            SizedBox(height: 12),

            _buildBudgetCard(
              title: '총 수입',
              value: '1,300,000원',
              sub: '예정 1,000,000원',
              backgroundColor: Color(0xFFFFA448),
            ),
            SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('자산', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('3,428,983원', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    _buildAccountRow('어디은행', '103,012원'),
                    _buildAccountRow('어디은행', '103,012원'),
                    _buildAccountRow('카드결제대금', '-103,012원'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { //가계부 퀵작성
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuickAddScreen()),
          );
        },

        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '가계부'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '자산'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '마이페이지'),
        ],
        currentIndex: 2,
        onTap: (index) {
          print('선택된 인덱스: \$index');
        },
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required String value,
    required String sub,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAccountRow(String bank, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(bank, style: TextStyle(fontSize: 14)),
          Text(amount, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
