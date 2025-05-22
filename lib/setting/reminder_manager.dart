import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderManager {
  static Future<List<Map<String, String>>> loadReminderItems() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('reminder_item_')).toList();

    final List<Map<String, String>> items = [];
    for (var key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          items.add(Map<String, String>.from(decoded));
        }
      }
    }
    return items;
  }

  static Future<void> deleteReminderItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_item_$id');
  }

  static Future<void> saveReminderItem({
    required String id,
    required String content,
    required String category,
    required String amount,
    required String createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final reminder = {
      'id': id,
      'content': content,
      'category': category,
      'amount': amount,
      'createdAt': createdAt,
    };
    await prefs.setString('reminder_item_$id', jsonEncode(reminder));
  }
}
