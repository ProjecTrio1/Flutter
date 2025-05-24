import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationHelper {
  static Future<void> saveNotification({required String title, required String body}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString('alert_$now', jsonEncode({
      'id': now,
      'title': title,
      'body': body,
    }));
  }

  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('alert_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  static Future<List<Map<String, dynamic>>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('alert_')).toList();
    keys.sort((a, b) => b.compareTo(a));

    final items = <Map<String, dynamic>>[];
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        items.add(jsonDecode(jsonStr));
      }
    }
    return items;
  }

  static Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alert_$id');
  }
}
