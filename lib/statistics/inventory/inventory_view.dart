import 'dart:io';
import 'package:flutter/material.dart';
import '../../style/main_style.dart';
import '../../style/inventory_style.dart';

class InventoryView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isCartView;
  final void Function(Map<String, dynamic> item, int index) onTap;

  const InventoryView({
    super.key,
    required this.items,
    required this.isCartView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
      subtitle: Text('$price원 / $date', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildIngredientTile(BuildContext context, Map<String, dynamic> item, int index) {
    final title = (item['title'] ?? '').toString().trim();
    final expiration = item['expirationDate'] ?? '';

    return ListTile(
      onTap: () => onTap(item, index),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        expiration.isNotEmpty ? '유통기한: $expiration' : '',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}