import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/note_style.dart';
import '../style/main_style.dart';

class QuickAddScreen extends StatefulWidget {
  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _amountController = TextEditingController();
  final _contentController = TextEditingController();
  final _memoController = TextEditingController();
  final _createdAtController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedCategory;
  bool isRegularExpense = false;
  bool notifyOverspend = false;
  bool isIncome = true;

  final _expensecategories = ['식비', '카페/디저트', '교통/차량', '쇼핑/생활/뷰티', '건강/의료', '교육/학원', '문화/여가', '기타'];
  final _incomecategories = ['월급', '용돈', '기타'];

  @override
  void initState() {
    super.initState();
    _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _selectedDateTime = combined;
          _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(combined);
        });
      }
    }
  }

  Future<void> submitNoteAdd() async {
    if (_selectedCategory == null || _amountController.text.isEmpty || _createdAtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리, 금액, 날짜 입력은 필수입니다.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('http://10.0.2.2:8080/note/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': _selectedCategory,
        'content': _contentController.text,
        'amount': int.parse(_amountController.text),
        'isRegularExpense': isRegularExpense,
        'notifyOverspend': notifyOverspend,
        'createdAt': _selectedDateTime.toIso8601String(),
        'memo': _memoController.text,
        'isIncome': isIncome,
        'userID': userID,
      }),
    );

    final bodyString = utf8.decode(response.bodyBytes);
    print("서버 응답 : $bodyString");

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(bodyString);
        if (decoded is Map && decoded.containsKey('recommendation')) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('과소비 알림'),
              content: Text(decoded['recommendation']),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 완료!')));
        }
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 응답 오류')));
      }
    } else {
      print("에러 상태코드 : ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패...')));
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = null;
      _amountController.clear();
      _memoController.clear();
      _contentController.clear();
    });
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NoteTextStyles.subHeader),
        SizedBox(height: 4),
        Container(
          decoration: NoteDecorations.inputBox,
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isNumber ? '숫자를 입력하세요' : '입력하세요',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text('가계부 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ToggleButtons(
              isSelected: [isIncome, !isIncome],
              onPressed: (index) {
                setState(() {
                  isIncome = index == 0;
                  _selectedCategory = isIncome ? _incomecategories.first : _expensecategories.first;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: isIncome ? AppColors.incomeBlue : AppColors.expenseRed,
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('수입')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('지출')),
              ],
            ),
            SizedBox(height: 20),

            Text('날짜', style: NoteTextStyles.subHeader),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _createdAtController,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderGray),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            _buildInput('금액', _amountController, isNumber: true),
            SizedBox(height: 16),

            Text('카테고리', style: NoteTextStyles.subHeader),
            SizedBox(height: 4),
            Container(
              decoration: NoteDecorations.inputBox,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
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
              ),
            ),
            SizedBox(height: 16),

            _buildInput('내용', _contentController),
            SizedBox(height: 16),

            _buildInput('메모 (선택)', _memoController),
            SizedBox(height: 24),

            SwitchListTile(
              title: Text('정기 지출로 등록'),
              value: isRegularExpense,
              onChanged: (val) => setState(() => isRegularExpense = val),
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
            SwitchListTile(
              title: Text('한 달 후 과소비 확인 알림'),
              value: notifyOverspend,
              onChanged: (val) => setState(() => notifyOverspend = val),
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: submitNoteAdd,
              child: Text('저장'),
              style: NoteDecorations.filledButton,
            ),
          ],
        ),
      ),
    );
  }
}
