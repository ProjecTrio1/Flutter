import 'package:flutter/material.dart';
import '../../style/main_style.dart';

class InventoryView extends StatelessWidget {
  final List<Map<String, String>> items;
  final bool isGridView;
  final bool isSelectionMode;
  final Set<int> selectedIndexes;
  final void Function(int index) onTapItem;
  final void Function(Map<String, String> item) onOpenEdit;

  const InventoryView({
    super.key,
    required this.items,
    required this.isGridView,
    required this.isSelectionMode,
    required this.selectedIndexes,
    required this.onTapItem,
    required this.onOpenEdit,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedIndexes.contains(index);
        return GestureDetector(
          onTap: isSelectionMode ? () => onTapItem(index) : () => onOpenEdit(item),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 36),
                const SizedBox(height: 6),
                Text(
                  item['title'] ?? '',
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedIndexes.contains(index);
        return ListTile(
          tileColor: isSelected ? AppColors.surface : null,
          leading: const Icon(Icons.image_outlined),
          title: Text(item['title'] ?? '', style: AppTextStyles.body),
          subtitle: Text(
            '${item['price'] ?? ''} / ${item['date'] ?? ''}',
            style: AppTextStyles.body,
          ),
          trailing: isSelectionMode
              ? Checkbox(
            value: isSelected,
            onChanged: (_) => onTapItem(index),
          )
              : null,
          onTap: isSelectionMode ? () => onTapItem(index) : () => onOpenEdit(item),
        );
      },
    );
  }
}
