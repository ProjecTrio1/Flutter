import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InventoryStorage {
  static const _key = 'inventory_items';

  // 항목 불러오기
  static Future<List<Map<String, dynamic>>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) {
        final item = Map<String, dynamic>.from(e);
        item['parsedItems'] = _normalizeParsedItems(item['parsedItems']);
        return item;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // 항목 저장
  static Future<void> saveItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items);
    await prefs.setString(_key, jsonString);
  }

  // 단일 항목 추가
  static Future<void> addItem(Map<String, dynamic> newItem) async {
    final items = await loadItems();
    items.add(newItem);
    await saveItems(items);
  }

  // 항목 업데이트
  static Future<void> updateItem(int index, Map<String, dynamic> updatedItem) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  // 다중 항목 삭제
  static Future<void> deleteItems(Set<int> indexes) async {
    final items = await loadItems();
    final filtered = items.asMap().entries
        .where((e) => !indexes.contains(e.key))
        .map((e) => e.value)
        .toList();
    await saveItems(filtered);
  }

  // 전체 삭제
  static Future<void> clearItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static List<Map<String, dynamic>> _normalizeParsedItems(dynamic data) {
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
}

