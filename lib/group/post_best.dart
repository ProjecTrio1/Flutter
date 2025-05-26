import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import 'post_detail.dart';

class GroupBestScreen extends StatefulWidget {
  const GroupBestScreen({super.key});

  @override
  State<GroupBestScreen> createState() => _GroupBestScreenState();
}

class _GroupBestScreenState extends State<GroupBestScreen> {
  List<Map<String, dynamic>> bestPosts = [];
  String _sortMode = 'recommend'; // 'recommend' or 'recent'
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBestPosts();
  }

  Future<void> _fetchBestPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('${AppConfig.baseUrl}/question/list?userID=$userID');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<Map<String, dynamic>> filtered = data
            .cast<Map<String, dynamic>>()
            .where((post) => ((post['voter'] as List?)?.length ?? 0) >= 10)
            .toList();

        setState(() {
          bestPosts = filtered;
          isLoading = false;
        });
      } else {
        print('베스트 글 요청 실패: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('예외 발생: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _sortedPosts {
    final sorted = [...bestPosts];
    if (_sortMode == 'recommend') {
      sorted.sort((a, b) => ((b['voter'] as List?)?.length ?? 0)
          .compareTo((a['voter'] as List?)?.length ?? 0));
    } else if (_sortMode == 'recent') {
      sorted.sort((a, b) => (b['createDate'] ?? '').compareTo(a['createDate'] ?? ''));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('베스트 글'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortMode = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'recommend', child: Text('추천순')),
              PopupMenuItem(value: 'recent', child: Text('최신순')),
            ],
            icon: Icon(Icons.sort),
            tooltip: '정렬 방식',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _sortedPosts.isEmpty
          ? Center(child: Text('추천 수 10 이상인 글이 없습니다.'))
          : ListView.builder(
        itemCount: _sortedPosts.length,
        itemBuilder: (context, index) {
          final post = _sortedPosts[index];
          final subject = post['subject'] ?? '제목 없음';
          final content = post['content'] ?? '';
          final likes = (post['voter'] as List?)?.length ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(subject, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  Text('$likes'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupPostDetailScreen(post: post),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
