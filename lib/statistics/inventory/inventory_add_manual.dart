import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../style/main_style.dart';
import '../../style/inventory_style.dart';

List<Map<String, dynamic>> normalizeParsedItems(dynamic data) {
  if (data == null) return [];
  if (data is String) {
    return data.split(',').map((e) => {'name': e.trim(), 'amount': ''}).toList();
  }
  if (data is List) {
    if (data.isNotEmpty && data.first is String) {
      return data.map((e) => {'name': e, 'amount': ''}).toList();
    } else if (data.isNotEmpty && data.first is Map) {
      return data.map((e) => {
        'name': e['name'] ?? '',
        'amount': e['amount'] ?? '',
      }).toList();
    }
  }
  return [];
}

class InventoryAddManualPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const InventoryAddManualPage({this.initialData, super.key});

  @override
  State<InventoryAddManualPage> createState() => _InventoryAddManualPageState();
}

class _InventoryAddManualPageState extends State<InventoryAddManualPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _expirationController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedExpiration;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _priceController.text = data['price'] ?? '';
      _dateController.text = data['date'] ?? '';
      _expirationController.text = data['expirationDate'] ?? '';
      final parsedList = normalizeParsedItems(data['parsedItems']);
      _amountController.text = parsedList.isNotEmpty ? parsedList[0]['amount'] ?? '' : '';
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
  }

  Future<void> _selectDate({required bool isExpiration}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiration ? (_selectedExpiration ?? _selectedDate) : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );

    if (picked != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(picked);
        if (isExpiration) {
          _selectedExpiration = picked;
          _expirationController.text = formatted;
        } else {
          _selectedDate = picked;
          _dateController.text = formatted;
        }
      });
    }
  }

  void _submitItem() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료 이름은 필수 항목입니다.')),
      );
      return;
    }

    final item = {
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'date': _dateController.text.trim(),
      'expirationDate': _expirationController.text.trim(),
      'imagePath': null,
      'parsedItems': [
        {
          'name': _titleController.text.trim(),
          'amount': _amountController.text.trim(),
        }
      ],
      'category': '식품',
    };

    Navigator.pop(context, item);
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumber = false, bool isDate = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InventoryTextStyles.subHeader),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: isDate,
            child: Container(
              decoration: InventoryDecorations.inputBox,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '입력하세요',
                ),
              ),
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
      appBar: AppBar(title: const Text('재료 수동 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInputField('재료 이름', _titleController),
            const SizedBox(height: 16),
            _buildInputField('수량 (예: 1개, 100g)', _amountController),
            const SizedBox(height: 16),
            _buildInputField('가격 (선택)', _priceController, isNumber: true),
            const SizedBox(height: 16),
            _buildInputField('구매일 (선택)', _dateController, isDate: true, onTap: () => _selectDate(isExpiration: false)),
            const SizedBox(height: 16),
            _buildInputField('소비기한 (선택)', _expirationController, isDate: true, onTap: () => _selectDate(isExpiration: true)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitItem,
              style: InventoryDecorations.filledButton,
              child: const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}