import 'package:flutter/material.dart';
import '../../../style/main_style.dart';

class InventoryParsedItemPreviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> parsedItems;

  const InventoryParsedItemPreviewPage({super.key, required this.parsedItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('인식된 재료 미리보기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: parsedItems.isEmpty
            ? const Center(child: Text('인식된 재료가 없습니다.', style: AppTextStyles.body))
            : ListView.separated(
          itemCount: parsedItems.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = parsedItems[index];
            final name = item['name']?.toString() ?? '';
            final amount = item['amount']?.toString() ?? '';
            return ListTile(
              title: Text(name, style: AppTextStyles.body),
              subtitle: amount.isNotEmpty
                  ? Text('수량: $amount', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))
                  : null,
            );
          },
        ),
      ),
    );
  }
}