import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InventoryStorage {
  static const _key = 'inventory_items';

  static Future<List<Map<String, String>>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveItems(List<Map<String, String>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items);
    await prefs.setString(_key, jsonString);
  }

  static Future<void> addItem(Map<String, String> newItem) async {
    final items = await loadItems();
    items.add(newItem);
    await saveItems(items);
  }

  static Future<void> updateItem(int index, Map<String, String> updatedItem) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  static Future<void> deleteItems(Set<int> indexes) async {
    final items = await loadItems();
    final filtered = items.asMap().entries.where((e) => !indexes.contains(e.key)).map((e) => e.value).toList();
    await saveItems(filtered);
  }

  static Future<void> clearItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
