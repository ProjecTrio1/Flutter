import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _imageFile;

  final List<String> _categories = ['의류', '식품', '전자기기'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _priceController.text = widget.initialData!['price'] ?? '';
      _dateController.text = widget.initialData!['date'] ?? '';
      // 메모는 실제 연동되면 불러오기
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _saveItem() {
    final title = _titleController.text;
    final price = _priceController.text;
    final date = _dateController.text;
    final memo = _memoController.text;
    final category = _selectedCategory;

    // TODO: 저장 로직 처리
    print('저장됨: $title / $price / $date / $memo / $category');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '항목 수정' : '항목 추가'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: _imageFile != null
                ? Image.file(_imageFile!, height: 160, fit: BoxFit.cover)
                : Container(
              height: 160,
              color: Colors.grey[300],
              child: Icon(Icons.add_a_photo, size: 40),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: '항목명'),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: InputDecoration(labelText: '카테고리'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: '가격 (선택)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _dateController,
            decoration: InputDecoration(labelText: '날짜 (선택)', hintText: '예: 2025-04-25'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _memoController,
            decoration: InputDecoration(labelText: '메모 (선택)'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveItem,
            child: Text(isEdit ? '수정 완료' : '추가하기'),
          ),
        ],
      ),
    );
  }
}
