import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../style/main_style.dart';
import '../../style/note_style.dart';
import 'dart:io';

class InventoryAddItemPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, String>? initialData;

  const InventoryAddItemPage({this.isEdit = false, this.initialData, super.key});

  @override
  State<InventoryAddItemPage> createState() => _InventoryAddItemPageState();
}

class _InventoryAddItemPageState extends State<InventoryAddItemPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _memoController = TextEditingController();
  String _selectedCategory = '의류';
  DateTime _selectedDate = DateTime.now();
  File? _imageFile;

  final List<String> _categories = ['식품', '의류', '뷰티'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialData != null) {
      final data = widget.initialData!;
      _titleController.text = data['title'] ?? '';
      _priceController.text = data['price'] ?? '';
      _dateController.text = data['date'] ?? '';
      _memoController.text = data['memo'] ?? '';
      _selectedCategory = data['category'] ?? _categories.first;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveItem() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('항목명은 필수입니다.')),
      );
      return;
    }
    final item = {
      'title': _titleController.text,
      'price': _priceController.text,
      'date': _dateController.text,
      'memo': _memoController.text,
      'category': _selectedCategory,
    };
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text(isEdit ? '항목 수정' : '항목 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.borderGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 6),
                      Text("미디어 추가", style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '항목명'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '가격 (선택)'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '날짜 (선택)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(labelText: '메모 (선택)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveItem,
              style: NoteDecorations.filledButton,
              child: Text(isEdit ? '수정 완료' : '추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
