import 'package:flutter/material.dart';
import '../config.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/note_style.dart';
import '../style/main_style.dart';
import '../setting/category_setting.dart';
import '../setting/category_helper.dart';
import '../setting/reminder_manager.dart';
import '../layout/notification_helper.dart';

class QuickAddScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  final VoidCallback? onSaved;

  const QuickAddScreen({this.existingNote, this.onSaved});
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

  List<String> _expenseCategories = [];
  List<String> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
    _loadCategories();
    final note = widget.existingNote;
    if (note != null) {
      isIncome = note['isIncome'] == true;
      _amountController.text = note['amount'].toString();
      _contentController.text = note['content'] ?? '';
      _memoController.text = note['memo'] ?? '';
      _selectedDateTime = DateTime.parse(note['createdAt']).toLocal();
      _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
      _selectedCategory = note['category'];
    }
  }

  Future<void> _loadCategories() async {
    final expense = await CategoryStorage.loadExpenseCategories();
    final income = await CategoryStorage.loadIncomeCategories();

    setState(() {
      _expenseCategories = expense;
      _incomeCategories = income;
      _selectedCategory ??= isIncome ? _incomeCategories.first : _expenseCategories.first;
    });
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

  Future<int> _getMonthlyTotalForCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userID');
    final year = _selectedDateTime.year;
    final month = _selectedDateTime.month.toString().padLeft(2, '0');

    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/note/total?userId=$userId&category=$category&year=$year&month=$month'));
      if (response.statusCode == 200) {
        print("category total 응답: ${response.body}");
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return decoded['total'] ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> submitNoteAdd() async {
    if (_selectedCategory == null ||
        _amountController.text.isEmpty ||
        _createdAtController.text.isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리, 금액, 날짜, 내용을 모두 입력하세요.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = widget.existingNote != null
        ? Uri.parse('${AppConfig.baseUrl}/note/update/${widget.existingNote!['id']}')
        : Uri.parse('${AppConfig.baseUrl}/note/add');
    final response = widget.existingNote != null
      ? await http.put(
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
        )
      : await http.post(
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

    if (response.statusCode == 200) {
      final bodyString = utf8.decode(response.bodyBytes);
      print("서버 응답 : $bodyString");

      final now = DateTime.now().toIso8601String();

      if (notifyOverspend && !isIncome) {
        final decoded = jsonDecode(bodyString);
        final noteId = decoded['save']['id'].toString();

        await ReminderManager.saveReminderItem(
          id: noteId,
          content: _contentController.text,
          category: _selectedCategory ?? '',
          amount: _amountController.text,
          createdAt: now,
        );
      }
      try {
        if (bodyString.trim().startsWith('{')) {
          final decoded = jsonDecode(bodyString);
          final message = decoded['recommendation'] as String? ?? '';

          if (decoded is Map &&
              decoded.containsKey('recommendation') &&
              message.trim().isNotEmpty) {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('과소비 알림'),
                content: Text(message),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
              ),
            );
          }
        }

        if (!isIncome) {
          final categoryLimit = await CategoryStorage.getLimit(_selectedCategory!);
          final notifyLimit = await CategoryStorage.getLimitNotify(_selectedCategory!);
          if (notifyLimit && categoryLimit > 0) {
            final totalSpent = await _getMonthlyTotalForCategory(_selectedCategory!);

            final addedAmount = int.parse(_amountController.text);
            print("총합: $totalSpent / 한도: $categoryLimit / 추가금액: $addedAmount");
            if (totalSpent + addedAmount > categoryLimit) {
              final message = '${_selectedCategory!} 항목이 이번 달 한도 ${categoryLimit}원을 초과했습니다.';
              await NotificationHelper.saveNotification(title: '지출 한도 초과', body: message);

              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('지출 한도 알림'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 완료!')));
        if (widget.onSaved != null) widget.onSaved!();
        Navigator.pop(context, _selectedDateTime);

      } catch (e) {
        print("JSON 파싱 오류: $e");
        print("📨 응답 status: ${response.statusCode}");
        print("📨 응답 body: ${response.body}");
        print("📨 디코딩된 body: ${utf8.decode(response.bodyBytes)}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 응답 오류')));
        Navigator.pop(context, true);
      }
      _resetForm();
    } else {
      print("에러 상태코드 : ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패')));
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
                  _selectedCategory = (isIncome ? _incomeCategories : _expenseCategories).first;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('카테고리', style: NoteTextStyles.subHeader),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategorySettingScreen()),
                    ).then((_) => _loadCategories());
                  },
                  icon: Icon(Icons.settings, size: 18, color: AppColors.primary),
                  label: Text('설정', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Container(
              decoration: NoteDecorations.inputBox,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: (isIncome ? _incomeCategories : _expenseCategories).map((String value) {
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
            if (!isIncome)...[
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
            ],
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