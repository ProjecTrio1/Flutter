import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuickAddScreen extends StatefulWidget {
  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _createdAtController = TextEditingController();
  String? _selectedCategory;
  bool isRegularExpense = false;
  bool notifyOverspend = false;
  bool isIncome = true;

  final List<String> _expensecategories = ['식비/카페', '교통', '쇼핑', '고정지출', '기타'];
  final List<String> _incomecategories= ['월급', '용돈', '기타'];

  Future<void> submitNoteAdd() async {
    if (_selectedCategory == null || _amountController.text.isEmpty ||
        _createdAtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리, 금액, 날짜 입력은 필수입니다.')),
      );
      return;
    }
    final url = Uri.parse(
        'http://10.0.2.2:8080/note/add'); // Android 에뮬레이터 기준 IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': _selectedCategory,
        'content' : _contentController.text,
        'amount': int.parse(_amountController.text),
        'isRegularExpense': isRegularExpense,
        'notifyOverspend': notifyOverspend,
        'createdAt': DateTime.parse(_createdAtController.text).toIso8601String(),
        'memo': _memoController.text, //입력 안해도 괜찮음
        'isIncome': isIncome,
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 완료!')),
      );
      _resetForm();
    } else {
      print('상태 코드 : ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 실패...')),
      );
    }
  }
  void _resetForm(){
    setState(() {
      _selectedCategory = null;
      _amountController.clear();
      _memoController.clear();
      _contentController.clear();
    });
  }

  @override
  void initState(){
    super.initState();
    _createdAtController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _createdAtController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '날짜',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
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
              value: _selectedCategory,
              isExpanded: true,
              items: (isIncome ? _incomecategories : _expensecategories).map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: '내용을 입력하세요',
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
              onPressed: submitNoteAdd,
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
  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );
    if(picked != null){
      setState((){
        _createdAtController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
