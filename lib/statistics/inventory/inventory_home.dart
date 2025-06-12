import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Set<int> _selectedIngredientIndexes = {};
  bool _selectAll = false;

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

  Future<void> _startCookingWithSelected() async {
    // 디버깅용
    print('ingredientItems: $ingredientItems');
    print('selected indexes: $_selectedIngredientIndexes');

    final selectedIngredients = _selectedIngredientIndexes
        .map((i) {
      final item = ingredientItems[i];
      // name 키 없으면 title 키로 대체
      return (item['name'] ?? item['title'] ?? '').toString().trim();
    })
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    print('전송할 재료: $selectedIngredients');

    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 재료가 없습니다.')),
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
      final result = await AIRecipeAPI.requestRecipe(selectedIngredients.join(', '));
      final parsed = result['parsed'];

      if (context.mounted) {
        Navigator.pop(context);
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

  List<Map<String, dynamic>> get _filteredItems {
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
                      tooltip: _selectAll ? '전체 해제' : '전체 선택',
                      onPressed: () {
                        setState(() {
                          _selectAll = !_selectAll;
                          if (_selectAll) {
                            _selectedIngredientIndexes = Set<int>.from(ingredientItems.asMap().keys);
                          } else {
                            _selectedIngredientIndexes.clear();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.restaurant_menu),
                      tooltip: '선택 재료로 레시피 추천',
                      onPressed: _selectedIngredientIndexes.isEmpty ? null : _startCookingWithSelected,
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _navigateToAddManual,
                      icon: const Icon(Icons.add),
                      label: const Text("재료 수동 추가"),
                      style: InventoryDecorations.outlinedIconButton,
                    ),
                  ],
                ),
              Expanded(
                child: showItems.isEmpty
                    ? const Center(child: Text('저장된 내역이 없습니다.', style: AppTextStyles.body))
                    : InventoryView(
                  items: showItems,
                  isCartView: isCartView,
                  onTap: _onTapItem,
                  onDelete: _confirmDelete,
                  selectedIndexes: _selectedIngredientIndexes,
                  onSelect: (int index, bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedIngredientIndexes.add(index);
                      } else {
                        _selectedIngredientIndexes.remove(index);
                      }
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
