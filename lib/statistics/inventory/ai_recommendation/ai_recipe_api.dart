import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config.dart';

class AIRecipeAPI {
  static Future<Map<String, dynamic>> requestRecipe(String ingredientsKor) async {
    final uri = Uri.parse('${AppConfig.flaskUrl}/generate-recipe');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredientsKor}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('레시피 생성 실패: ${response.statusCode}');
    }
  }
}
