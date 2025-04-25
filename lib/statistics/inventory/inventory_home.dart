import 'package:flutter/material.dart';
import 'inventory_detail.dart';
import 'inventory_add_item.dart';
import 'view_mode.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  String selectedCategory = '의류';
  final List<String> categories = ['의류', '식품', '전자기기'];

  final List<String> periods = ['월간', '주간', '전체'];
  int periodIndex = 0;

  ViewMode viewMode = ViewMode.image;

  String get currentPeriod => periods[periodIndex];

  void _nextPeriod() {
    setState(() {
      periodIndex = (periodIndex + 1) % periods.length;
    });
  }

  void _setViewMode(ViewMode mode) {
    setState(() => viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모아보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InventoryAddItemPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 및 기간 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                OutlinedButton(
                  onPressed: _nextPeriod,
                  child: Text(currentPeriod),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 보기 모드 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: () => _setViewMode(ViewMode.image),
                  color: viewMode == ViewMode.image ? Colors.blue : null,
                ),
                IconButton(
                  icon: const Icon(Icons.view_list),
                  onPressed: () => _setViewMode(ViewMode.detailed),
                  color: viewMode == ViewMode.detailed ? Colors.blue : null,
                ),
                IconButton(
                  icon: const Icon(Icons.text_snippet),
                  onPressed: () => _setViewMode(ViewMode.text),
                  color: viewMode == ViewMode.text ? Colors.blue : null,
                ),
              ],
            ),

            // 상세 항목 표시
            Expanded(
              child: InventoryDetailView(
                category: selectedCategory,
                viewMode: viewMode,
                period: currentPeriod,
              ),
            )
          ],
        ),
      ),
    );
  }
}
