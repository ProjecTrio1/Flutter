import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../style/main_style.dart';
import '../../style/inventory_style.dart';
import 'inventory_parser_dummy.dart';

class InventoryAddCartPage extends StatefulWidget {
  const InventoryAddCartPage({super.key});

  @override
  State<InventoryAddCartPage> createState() => _InventoryAddCartPageState();
}

class _InventoryAddCartPageState extends State<InventoryAddCartPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _imageFile;
  List<String> _parsedItems = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _imageFile = file);

      final parsed = await InventoryParserDummy.analyze(file);
      setState(() => _parsedItems = parsed);
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
    if (_imageFile == null || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진과 가격은 필수입니다.')),
      );
      return;
    }

    final item = {
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'date': _dateController.text.trim(),
      'imagePath': _imageFile!.path,
      'parsedItems': _parsedItems,
      'category': '식품',
    };

    Navigator.pop(context, item);
  }

  Widget _buildInput(String label, TextEditingController controller,
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
      appBar: AppBar(title: const Text('장바구니 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.borderGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 6),
                      Text("사진 추가", style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInput('제목 (선택)', _titleController),
            const SizedBox(height: 12),
            _buildInput('총 가격', _priceController, isNumber: true),
            const SizedBox(height: 12),
            _buildInput('구매일', _dateController, isDate: true, onTap: _selectDate),
            const SizedBox(height: 20),
            if (_parsedItems.isNotEmpty) ...[
              const Text('인식된 재료', style: InventoryTextStyles.subHeader),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _parsedItems.map((e) => Chip(label: Text(e))).toList(),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _saveItem,
              style: InventoryDecorations.filledButton,
              child: const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
