import 'package:flutter/material.dart';
import 'inventory_add_item.dart';
import 'inventory_item_card.dart';
import 'view_mode.dart';

class InventoryDetailView extends StatelessWidget {
  final String category;
  final ViewMode viewMode;
  final String period;

  const InventoryDetailView({
    required this.category,
    required this.viewMode,
    required this.period,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final items = {
      '의류': [
        {'title': '티셔츠', 'price': '15000', 'date': '2025-04-21'},
        {'title': '바지', 'price': '29000', 'date': '2025-04-22'},
      ],
      '전자기기': [
        {'title': '이어폰', 'price': '70000', 'date': '2025-04-10'},
      ],
      '식품': [
        {'title': '소고기', 'price': '32000', 'date': '2025-03-28'},
      ],
    };

    final filtered = (items[category] ?? []).where((item) {
      final date = DateTime.tryParse(item['date'] ?? '') ?? DateTime(2000);
      if (period == '주간') {
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(Duration(days: 6));
        return date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end) || (date.isAfter(start) && date.isBefore(end));
      } else if (period == '월간') {
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
        return date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end) || (date.isAfter(start) && date.isBefore(end));
      } else {
        return true; // 전체
      }
    }).toList();

    String getDateRangeText() {
      if (period == '주간') {
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(Duration(days: 6));
        return '(${_formatDate(start)} ~ ${_formatDate(end)})';
      } else if (period == '월간') {
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
        return '(${_formatDate(start)} ~ ${_formatDate(end)})';
      }
      return '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (period != '전체')
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(getDateRangeText(), style: TextStyle(color: Colors.grey)),
          ),
        Expanded(
          child: _buildView(filtered, context),
        ),
      ],
    );
  }

  Widget _buildView(List<Map<String, String>> items, BuildContext context) {
    switch (viewMode) {
      case ViewMode.image:
        return GridView.builder(
          padding: EdgeInsets.only(top: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InventoryItemCard(
              title: item['title']!,
              showImage: true,
              onTap: () => _navigateEdit(context, item),
            );
          },
        );
      case ViewMode.detailed:
        return ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InventoryItemCard(
              title: item['title']!,
              price: item['price'],
              date: item['date'],
              showImage: true,
              onTap: () => _navigateEdit(context, item),
            );
          },
        );
      case ViewMode.text:
        return ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InventoryItemCard(
              title: item['title']!,
              price: item['price'],
              date: item['date'],
              showImage: false,
              onTap: () => _navigateEdit(context, item),
            );
          },
        );
    }
  }

  void _navigateEdit(BuildContext context, Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryAddItemPage(
          isEdit: true,
          initialData: item,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${_two(date.month)}.${_two(date.day)}';
  }

  String _two(int n) => n < 10 ? '0$n' : '$n';
}
