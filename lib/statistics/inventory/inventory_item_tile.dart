import 'package:flutter/material.dart';
import '../../style/main_style.dart';

class InventoryItemTile extends StatelessWidget {
  final String title;
  final String? price;
  final String? date;
  final bool showImage;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onSelectChanged;

  const InventoryItemTile({
    required this.title,
    this.price,
    this.date,
    this.showImage = true,
    this.isSelected = false,
    this.onTap,
    this.onSelectChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isSelected ? AppColors.surface : null,
      leading: showImage
          ? Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_outlined, color: Colors.grey[700]),
      )
          : null,
      title: Text(title, style: AppTextStyles.body),
      subtitle: (price != null || date != null)
          ? Text(
        '${price ?? ''}${price != null && date != null ? ' / ' : ''}${date ?? ''}',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      )
          : null,
      trailing: onSelectChanged != null
          ? Checkbox(
        value: isSelected,
        onChanged: onSelectChanged,
      )
          : null,
      onTap: onTap,
    );
  }
}
