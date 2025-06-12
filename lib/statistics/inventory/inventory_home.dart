import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../style/main_style.dart';
import '../../style/inventory_style.dart';

import 'inventory_add_cart.dart';
import 'inventory_add_manual.dart';
import 'inventory_view.dart';
import 'inventory_storage.dart';
import 'inventory_detail_view.dart';

import 'ai_recommendation/ai_recipe_api.dart';
import 'ai_recommendation/ai_recipe_result_page.dart';
import 'ai_recommendation/ai_recipe_bookmark.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final List<String> categories = ['식품', '의류'];
  int selectedTabIndex = 0;
  String selectedCategory = '식품';
  bool sortLatestFirst = true;

  List<Map<String, dynamic>> allItems = [];

  bool get isCartView => selectedTabIndex == 0;
  bool get isIngredientView => selectedTabIndex == 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loaded = await InventoryStorage.loadItems();
    setState(() => allItems = loaded);
  }

  Future<void> _navigateToAddCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InventoryAddCartPage()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() => allItems.add(result));
      await InventoryStorage.saveItems(allItems);
    }
  }

  Future<void> _startCooking() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('inventory_items');
    if (jsonStr == null || jsonStr.isEmpty) return;

    final decoded = jsonDecode(jsonStr) as List;
    final items = decoded.map((e) => Map<String, dynamic>.from(e)).toList();

    final allIngredients = <String>{};
    for (final item in items) {
      if (item['category'] == '식품') {
        final parsedList = item['parsedItems'] as List<dynamic>? ?? [];
        for (final parsed in parsedList) {
          final ingredient = parsed is Map<String, dynamic> ? parsed['name'] : parsed.toString();
          allIngredients.add(ingredient);
        }
      }
    }

    if (allIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 식품 재료가 없습니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("레시피 분석 중입니다..."),
          ],
        ),
      ),
    );

    try {
      final result = await AIRecipeAPI.requestRecipe(allIngredients.toList());
      final parsed = result['parsed'];

      if (context.mounted) {
        Navigator.pop(context); // 로딩 닫기
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AIRecipeResultPage(parsed: parsed),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('레시피 생성 실패: $e')),
        );
      }
    }
  }

  Future<void> _navigateToAddManual([Map<String, dynamic>? item, int? index]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryAddManualPage(initialData: item),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) allItems[index] = result;
        else allItems.add(result);
      });
      await InventoryStorage.saveItems(allItems);
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    final now = DateTime.now();
    final filtered = allItems.where((item) => item['category'] == selectedCategory).toList();
    filtered.sort((a, b) {
      final key = isIngredientView ? 'expirationDate' : 'date';
      final da = DateTime.tryParse(a[key] ?? '') ?? DateTime.now();
      final db = DateTime.tryParse(b[key] ?? '') ?? DateTime.now();
      return sortLatestFirst ? db.compareTo(da) : da.compareTo(db);
    });
    return filtered;
  }

  List<Map<String, dynamic>> get cartItems => _filteredItems.where((e) => e['imagePath'] != null).toList();
  List<Map<String, dynamic>> get ingredientItems => _filteredItems.where((e) => e['imagePath'] == null).toList();

  void _onTapItem(Map<String, dynamic> item, int index) {
    if (isIngredientView) {
      _navigateToAddManual(item, index);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InventoryDetailView(item: item)),
      );
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                allItems.removeAt(index);
              });
              await InventoryStorage.saveItems(allItems);
              Navigator.of(context).pop();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final showItems = isCartView ? cartItems : ingredientItems;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('모아보기'),
        actions: [
          if (selectedCategory == '식품') ...[
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              tooltip: 'AI 레시피 추천',
              onPressed: _startCooking,
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_outline),
              tooltip: '레시피 북마크',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIRecipeBookmarkPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigateToAddCart,
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [isCartView, isIngredientView],
                  onPressed: (index) => setState(() => selectedTabIndex = index),
                  children: const [
                    Icon(Icons.shopping_cart_outlined),
                    Icon(Icons.list_alt_outlined),
                  ],
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(sortLatestFirst ? Icons.arrow_downward : Icons.arrow_upward),
                  tooltip: sortLatestFirst ? '최신순' : '오래된순',
                  onPressed: () => setState(() => sortLatestFirst = !sortLatestFirst),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (selectedCategory == '의류')
              const Expanded(
                child: Center(
                  child: Text('의류 항목은 추후 업데이트 예정입니다.', style: AppTextStyles.body),
                ),
              )
            else ...[
              if (isIngredientView)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToAddManual(),
                    icon: const Icon(Icons.add),
                    label: const Text("재료 수동 추가"),
                    style: InventoryDecorations.outlinedIconButton,
                  ),
                ),
              Expanded(
                child: showItems.isEmpty
                    ? const Center(child: Text('저장된 내역이 없습니다.', style: AppTextStyles.body))
                    : InventoryView(
                  items: showItems,
                  isCartView: isCartView,
                  onTap: _onTapItem,
                  onDelete: _confirmDelete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
