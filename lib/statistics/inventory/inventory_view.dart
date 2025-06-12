import 'dart:io';
import 'package:flutter/material.dart';
import '../../style/main_style.dart';
import '../../style/inventory_style.dart';

class InventoryView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isCartView;
  final void Function(Map<String, dynamic> item, int index) onTap;
  final void Function(int index) onDelete;
  final Future<void> Function()? onRefresh;
  final Set<int>? selectedIndexes;
  final void Function(int index, bool selected)? onSelect;

  const InventoryView({
    super.key,
    required this.items,
    required this.isCartView,
    required this.onTap,
    required this.onDelete,
    this.onRefresh,
    this.selectedIndexes,
    this.onSelect,
  });

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: items.isEmpty
          ? const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 300,
          child: Center(child: Text('저장된 내역이 없습니다.', style: AppTextStyles.body)),
        ),
      )
          : ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            color: Colors.white,
            child: isCartView
                ? _buildCartTile(context, item, index)
                : _buildIngredientTile(context, item, index),
          );
        },
      ),
    );
  }

  Widget _buildCartTile(BuildContext context, Map<String, dynamic> item, int index) {
    final title = (item['title'] ?? '').toString().trim();
    final price = item['price'] ?? '';
    final date = item['date'] ?? '';
    final imagePath = item['imagePath'];
    final displayTitle = title.isNotEmpty ? title : date;

    return ListTile(
      onTap: () => onTap(item, index),
      leading: imagePath != null && File(imagePath).existsSync()
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      )
          : Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported),
      ),
      title: Text(
        displayTitle,
        style: AppTextStyles.body.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$price원 / $date',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildIngredientTile(BuildContext context, Map<String, dynamic> item, int index) {
    final title = (item['title'] ?? '').toString().trim();
    final expiration = (item['expirationDate'] ?? '').toString().trim();
    final parsed = normalizeParsedItems(item['parsedItems']);
    final amount = parsed.isNotEmpty ? (parsed[0]['amount'] ?? '') : '';
    final detailText = [
      if (amount.isNotEmpty) amount,
      if (expiration.isNotEmpty) '소비기한: $expiration',
    ].join(' / ');

    final bool isSelected = selectedIndexes?.contains(index) ?? false;

    return ListTile(
      onTap: () => onTap(item, index),
      leading: onSelect != null
          ? Checkbox(
        value: isSelected,
        onChanged: (value) => onSelect!(index, value ?? false),
      )
          : null,
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        detailText.isNotEmpty ? detailText : ' ',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      // trailing: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     if (onSelect != null)
      //       IconButton(
      //         icon: const Icon(Icons.delete, color: Colors.redAccent),
      //         onPressed: () => onDelete(index),
      //       ),
      //     const Icon(Icons.chevron_right),
      //   ],
      // ),
    );
  }
}
