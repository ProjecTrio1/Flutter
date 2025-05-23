import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../config.dart';

class HomeSummaryService {
  static Future<Map<String, int>?> fetchSummary(String year, String month) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userID');
      if (userId == null) return null;

      final uri = Uri.parse('${AppConfig.baseUrl}/note/summary?userId=$userId&year=$year&month=$month');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'income': decoded['income'],
          'expense': decoded['expense'],
        };
      } else {
        print('요약 정보 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('에러 발생: $e');
      return null;
    }
  }
}