import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../style/main_style.dart';
import '../../style/inventory_style.dart';
import '../../config.dart';
import 'inventory_storage.dart';

class InventoryAddCartPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? initialData;

  const InventoryAddCartPage({
    super.key,
    this.isEdit = false,
    this.initialData,
  });

  @override
  State<InventoryAddCartPage> createState() => _InventoryAddCartPageState();
}

class _InventoryAddCartPageState extends State<InventoryAddCartPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _imageFile;
  List<Map<String, dynamic>> _parsedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _priceController.text = widget.initialData!['price'] ?? '';
      _dateController.text = widget.initialData!['date'] ?? '';
      _imageFile = File(widget.initialData!['imagePath'] ?? '');
      _parsedItems = List<Map<String, dynamic>>.from(widget.initialData!['parsedItems'] ?? []);
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _parsedItems = [];
      });
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("분석 중입니다..."),
          ],
        ),
      ),
    );

    final uri = Uri.parse("${AppConfig.flaskUrl}/upload");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final List recognized = data['recognized'] ?? [];
        setState(() {
          _parsedItems = recognized.map<Map<String, dynamic>>((name) => {
            'name': name,
            'amount': '',
            'price': '',
            'expirationDate': '',
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('분석 실패')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    }
  }

  Future<void> _saveItem() async {
    if (_imageFile == null || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진과 가격은 필수입니다.')),
      );
      return;
    }

    final cartItem = {
      'id': widget.initialData?['id'] ?? UniqueKey().toString(),
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'date': _dateController.text.trim(),
      'imagePath': _imageFile!.path,
      'parsedItems': _parsedItems,
      'category': '식품',
    };

    // 기존 장바구니 항목 삭제
    if (widget.isEdit && widget.initialData?['id'] != null) {
      await InventoryStorage.deleteItemById(widget.initialData!['id']);

      // 연결된 재료 삭제
      final oldParsed = widget.initialData!['parsedItems'] as List?;
      if (oldParsed != null) {
        final allItems = await InventoryStorage.loadItems();
        for (final parsed in oldParsed) {
          final name = parsed['name'];
          final matched = allItems.where((item) =>
          item['imagePath'] == null &&
              item['parsedItems'] != null &&
              item['parsedItems'].first['name'] == name);
          for (final m in matched) {
            await InventoryStorage.deleteItem(m);
          }
        }
      }
    }

    // 장바구니 저장 (업데이트 방식)
    await InventoryStorage.addItem(cartItem);

    // 재료 저장
    for (final parsed in _parsedItems) {
      final newIngredient = {
        'title': parsed['name'],
        'price': parsed['price'],
        'date': _dateController.text.trim(),
        'expirationDate': parsed['expirationDate'],
        'imagePath': null,
        'parsedItems': [parsed],
        'category': '식품',
      };
      await InventoryStorage.addItem(newIngredient);
    }

    if (context.mounted) Navigator.pop(context, true);
  }


  void _editItemDialog(int index) {
    final item = _parsedItems[index];
    final nameCtrl = TextEditingController(text: item['name']);
    final amountCtrl = TextEditingController(text: item['amount']);
    final priceCtrl = TextEditingController(text: item['price']);
    final dateCtrl = TextEditingController(text: item['expirationDate']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상세 정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: '수량'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '소비기한 (예: 20250630)'),
              onChanged: (value) {
                String raw = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (raw.length == 8) {
                  final formatted = '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 8)}';
                  dateCtrl.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('취소')),
          TextButton(
            onPressed: () {
              setState(() {
                _parsedItems[index]['name'] = nameCtrl.text.trim();
                _parsedItems[index]['amount'] = amountCtrl.text.trim();
                _parsedItems[index]['price'] = priceCtrl.text.trim();
                _parsedItems[index]['expirationDate'] = dateCtrl.text.trim();
              });
              Navigator.pop(context, true);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('장바구니 추가'),

      actions: widget.isEdit
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await InventoryStorage.deleteItem(widget.initialData!);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
            },
          )
        ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Padding(
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
              _buildInput('구매일', _dateController),
              const SizedBox(height: 20),
              if (_parsedItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('인식된 재료', style: InventoryTextStyles.subHeader),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: '재료 추가',
                      onPressed: () {
                        setState(() {
                          _parsedItems.add({
                            'name': '',
                            'amount': '',
                            'price': '',
                            'expirationDate': '',
                          });
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: _parsedItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return ListTile(
                        title: Text(item['name'], style: AppTextStyles.body),
                        subtitle: (item['amount'] ?? '').isEmpty && (item['price'] ?? '').isEmpty && (item['expirationDate'] ?? '').isEmpty
                            ? const SizedBox(height: 0)
                            : Text(
                          '수량: ${item['amount'] ?? ''} / 가격: ${item['price'] ?? ''} / 기한: ${item['expirationDate'] ?? ''}',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () => _editItemDialog(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => setState(() => _parsedItems.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  ),
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
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InventoryTextStyles.subHeader),
        const SizedBox(height: 4),
        Container(
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
      ],
    );
  }
}
