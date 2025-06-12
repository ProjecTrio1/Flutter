import 'dart:io';
import 'package:flutter/material.dart';
import '../../style/main_style.dart';
import '../../style/note_style.dart';

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

class InventoryDetailView extends StatelessWidget {
  final Map<String, dynamic> item;

  const InventoryDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String title = item['title'] ?? '';
    final String price = item['price'] ?? '';
    final String date = item['date'] ?? '';
    final String imagePath = item['imagePath'] ?? '';
    final List<Map<String, dynamic>> parsedItems = normalizeParsedItems(item['parsedItems']);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('장바구니 상세 보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (imagePath.isNotEmpty && File(imagePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.borderGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(height: 20),

            if (title.isNotEmpty)
              _buildInfoRow('제목', title),
            if (price.isNotEmpty)
              _buildInfoRow('총 가격', '$price 원'),
            if (date.isNotEmpty)
              _buildInfoRow('날짜', date),

            const SizedBox(height: 20),
            const Text('분석된 재료 목록', style: NoteTextStyles.subHeader),
            const SizedBox(height: 10),
            parsedItems.isNotEmpty
                ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parsedItems.map((e) {
                final label = (e['amount'] ?? '').toString().isNotEmpty
                    ? '${e['name']} (${e['amount']})'
                    : e['name'];
                return Chip(label: Text(label));
              }).toList(),
            )
                : const Text('분석된 품목이 없습니다.', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.bold),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}
