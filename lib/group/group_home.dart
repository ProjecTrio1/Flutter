import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'post_best.dart';
import 'post_add.dart';
import 'post_detail.dart';
import 'post_scrap.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupHomeScreen extends StatefulWidget {
  final String username;
  final int userID;

  const GroupHomeScreen({
    super.key,
    required this.username,
    required this.userID,
  });

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/question/list?userID=$userID'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          posts = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('불러오기 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(' '),
            SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border),
            tooltip: '베스트',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupBestScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_outline),
            tooltip: '스크랩',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupScrapScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? Center(child: Text('등록된 글이 없습니다.'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final authorText = post['anonymous'] == true
              ? '익명'
              : post['author']['username'] ?? '알 수 없음';
          final dateStr = post['createDate']?.substring(0, 10) ?? '날짜 없음';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['subject'] ?? '제목 없음'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$authorText | $dateStr',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${(post['voter'] as List?)?.length ?? 0}'),
                  SizedBox(width: 8),
                  Icon(Icons.comment, size: 16),
                  SizedBox(width: 4),
                  Text('${(post['answerList'] as List?)?.length ?? 0}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/group/add');
          if (result == true) {
            await _fetchPosts();
          }
        },
        child: Icon(Icons.create),
        tooltip: '글쓰기',
      ),
    );
  }
}
