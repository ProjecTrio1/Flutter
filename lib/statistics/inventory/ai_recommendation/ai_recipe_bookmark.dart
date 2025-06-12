import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/main_style.dart';
import 'ai_recipe_result_page.dart';

class AIRecipeBookmarkPage extends StatefulWidget {
  const AIRecipeBookmarkPage({super.key});

  @override
  State<AIRecipeBookmarkPage> createState() => _AIRecipeBookmarkPageState();
}

class _AIRecipeBookmarkPageState extends State<AIRecipeBookmarkPage> {
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('recipe_bookmarks');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final List<dynamic> decoded = json.decode(jsonStr);
      setState(() {
        _bookmarks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _removeBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarks.removeAt(index);
    });
    await prefs.setString('recipe_bookmarks', json.encode(_bookmarks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('레시피 북마크')),
      backgroundColor: Colors.white,
      body: _bookmarks.isEmpty
          ? const Center(child: Text('북마크된 레시피가 없습니다.', style: AppTextStyles.body))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarks.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = _bookmarks[index];
          return ListTile(
            title: Text(item['title'] ?? '제목 없음', style: AppTextStyles.body),
            subtitle: Text(item['ingredients'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeBookmark(index),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AIRecipeResultPage(parsed: item)),
            ),
          );
        },
      ),
    );
  }
}
