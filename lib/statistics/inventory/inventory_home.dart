import 'package:flutter/material.dart';
import '../../style/main_style.dart';
import 'inventory_add_item.dart';
import 'inventory_item_tile.dart';
import 'inventory_view.dart';
import 'inventory_storage.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  String selectedCategory = '의류';
  final List<String> categories = ['의류', '식품', '뷰티'];

  final List<String> periods = ['전체', '월간'];
  int periodIndex = 0;

  bool isGridView = true;
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  List<Map<String, String>> items = [];

  String get currentPeriod => periods[periodIndex];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    items = await InventoryStorage.loadItems();
    setState(() {});
  }

  Future<void> _saveItems() async {
    await InventoryStorage.saveItems(items);
  }

  void _nextPeriod() => setState(() => periodIndex = (periodIndex + 1) % periods.length);

  void _toggleViewMode() => setState(() => isGridView = !isGridView);

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedIndexes.clear();
    });
  }

  void _toggleItemSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void _deleteSelectedItems() async {
    if (selectedIndexes.isEmpty) {
      setState(() => isSelectionMode = false);
      return;
    }

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text('선택한 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('삭제')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        items = items.asMap().entries.where((e) => !selectedIndexes.contains(e.key)).map((e) => e.value).toList();
        selectedIndexes.clear();
        isSelectionMode = false;
      });
      _saveItems();
    }
  }

  void _navigateToAdd([Map<String, String>? data, int? index]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryAddItemPage(
          isEdit: data != null,
          initialData: data,
        ),
      ),
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        if (index != null) items[index] = result;
        else items.add(result);
      });
      _saveItems();
    }
  }

  List<Map<String, String>> get _filteredItems {
    if (currentPeriod == '월간') {
      final now = DateTime.now();
      return items.where((item) {
        final dateStr = item['date'];
        if (dateStr == null || dateStr.isEmpty) return false;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;
        return date.year == now.year && date.month == now.month;
      }).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모아보기'),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: Icon(Icons.select_all),
              tooltip: '전체 선택',
              onPressed: () {
                setState(() {
                  selectedIndexes = Set.from(List.generate(_filteredItems.length, (i) => i));
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: '삭제',
              onPressed: _deleteSelectedItems,
            ),
          ]
          else ...[
            IconButton(icon: Icon(Icons.delete_outline), onPressed: _toggleSelectionMode),
            IconButton(icon: Icon(Icons.add), onPressed: () => _navigateToAdd()),
          ]
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedCategory = val!),
                    ),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(onPressed: _nextPeriod, child: Text(currentPeriod)),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [isGridView, !isGridView],
                      onPressed: (_) => _toggleViewMode(),
                      children: const [
                        Icon(Icons.grid_view),
                        Icon(Icons.view_list),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: InventoryView(
                items: _filteredItems,
                isGridView: isGridView,
                isSelectionMode: isSelectionMode,
                selectedIndexes: selectedIndexes,
                onTapItem: _toggleItemSelection,
                onOpenEdit: _navigateToAdd,
              ),
            )
          ],
        ),
      ),
    );
  }
}
