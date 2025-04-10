import 'package:flutter/material.dart';

class QuickAddScreen extends StatefulWidget {
  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String selectedCategory = '식비/카페';
  DateTime selectedDate = DateTime.now();
  bool isRegularExpense = false;
  bool notifyOverspend = false;
  bool isIncome = false;

  final List<String> categories = [
    '식비/카페', '교통', '쇼핑', '고정지출', '기타'
  ];

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submit() {
    final String amount = _amountController.text.trim();
    final String content = _contentController.text.trim();
    final String memo = _memoController.text.trim();

    if (amount.isEmpty || content.isEmpty) return;

    print('구분: ${isIncome ? '수입' : '지출'}');
    print('날짜: \$selectedDate');
    print('금액: \$amount');
    print('카테고리: \$selectedCategory');
    print('내용: \$content');
    print('메모: \$memo');
    print('정기지출: \$isRegularExpense');
    print('과소비알림: \$notifyOverspend');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('가계부 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ToggleButtons(
              isSelected: [isIncome, !isIncome],
              onPressed: (index) {
                setState(() {
                  isIncome = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: isIncome ? Colors.green : Colors.grey,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('수입'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('지출'),
                ),
              ],
            ),
            SizedBox(height: 20),

            Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedDate.year}. ${selectedDate.month.toString().padLeft(2, '0')}. ${selectedDate.day.toString().padLeft(2, '0')} (${['월','화','수','목','금','토','일'][selectedDate.weekday - 1]})',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            Text('금액', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: '금액을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 16),

            Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: '내용을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            SizedBox(height: 16),

            Text('메모', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                  hintText: '선택 사항',
                  hintStyle: TextStyle(color: Colors.grey))
            ),
            SizedBox(height: 24),

            SwitchListTile(
              title: Text('정기 지출로 등록'),
              value: isRegularExpense,
              onChanged: (val) {
                setState(() => isRegularExpense = val);
              },
            ),
            SwitchListTile(
              title: Text('한 달 후 과소비 확인 알림'),
              value: notifyOverspend,
              onChanged: (val) {
                setState(() => notifyOverspend = val);
              },
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              child: Text('저장'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
