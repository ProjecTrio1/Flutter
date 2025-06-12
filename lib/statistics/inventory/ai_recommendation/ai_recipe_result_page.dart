import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/main_style.dart';

class AIRecipeResultPage extends StatefulWidget {
  final Map<String, dynamic> parsed;
  const AIRecipeResultPage({super.key, required this.parsed});

  @override
  State<AIRecipeResultPage> createState() => _AIRecipeResultPageState();
}

class _AIRecipeResultPageState extends State<AIRecipeResultPage> {
  late String title;
  late String ingredients;
  late List<String> directions;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    title = widget.parsed['title']?.toString().trim() ?? '';
    ingredients = widget.parsed['ingredients']?.toString().trim() ?? '';
    directions = List<String>.from(widget.parsed['directions'] ?? []);
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('recipe_bookmarks') ?? '[]';
    final existing = List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
    final exists = existing.any((e) =>
    e['title'] == title && e['ingredients'] == ingredients);
    setState(() {
      isBookmarked = exists;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('recipe_bookmarks') ?? '[]';
    final existing = List<Map<String, dynamic>>.from(jsonDecode(jsonStr));

    final exists = existing.any((e) =>
    e['title'] == title && e['ingredients'] == ingredients);

    if (exists) {
      existing.removeWhere((e) =>
      e['title'] == title && e['ingredients'] == ingredients);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('북마크에서 제거되었습니다.')),
      );
    } else {
      existing.add(widget.parsed);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('북마크에 저장되었습니다.')),
      );
    }

    await prefs.setString('recipe_bookmarks', jsonEncode(existing));
    setState(() {
      isBookmarked = !exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title.isNotEmpty ? title : '레시피 결과'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.orange : Colors.grey,
            ),
            tooltip: isBookmarked ? '북마크 해제' : '북마크 저장',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('📌 요리 이름', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.body),
            const SizedBox(height: 24),

            Text('🧂 재료', style: AppTextStyles.title),
            const SizedBox(height: 8),
            ingredients.isNotEmpty
                ? Text(ingredients, style: AppTextStyles.body)
                : const Text('재료 정보가 없습니다.', style: AppTextStyles.body),
            const SizedBox(height: 24),

            Text('👨‍🍳 조리 방법', style: AppTextStyles.title),
            const SizedBox(height: 8),
            directions.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: directions
                  .asMap()
                  .entries
                  .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${e.key + 1}. ",
                        style: AppTextStyles.body),
                    Expanded(
                        child: Text(e.value,
                            style: AppTextStyles.body)),
                  ],
                ),
              ))
                  .toList(),
            )
                : const Text('조리 방법이 없습니다.', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
