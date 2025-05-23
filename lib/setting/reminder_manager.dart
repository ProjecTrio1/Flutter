import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config.dart';

class ReminderManager {
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

  static Future<void> deleteReminderItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_item_$id');
  }

  static Future<void> markOverspendAsFalse(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/note/overspend-off/$id'),
      );
      if (response.statusCode == 200) {
        print("notifyOverspend 해제 완료");
      } else {
        print("notifyOverspend 해제 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("notifyOverspend 예외: $e");
    }
  }

  static Future<String?> fetchFeedbackStatus(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/note/feedback/$id'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['userFeedback'] == true) return 'up';
        if (data['userFeedback'] == false) return 'down';
      } else {
        print("피드백 상태 불러오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("피드백 상태 예외: $e");
    }
    return null;
  }

  static Future<List<Map<String, String>>> loadReminderItems() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('reminder_item_')).toList();
    final List<Map<String, String>> items = [];

    for (var key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final map = Map<String, String>.from(decoded);
          final feedback = await fetchFeedbackStatus(map['id'] ?? '');
          map['feedback'] = feedback ?? '';
          items.add(map);
        }
      }
    }
    return items;
  }
}
