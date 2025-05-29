import 'package:flutter/material.dart';
import '../config.dart';
import 'post_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupScrapScreen extends StatefulWidget {
  const GroupScrapScreen({super.key});

  @override
  State<GroupScrapScreen> createState() => _GroupScrapScreenState();
}

class _GroupScrapScreenState extends State<GroupScrapScreen> {
  List<Map<String, dynamic>> scrapedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScrappedPosts();
  }

  Future<void> _fetchScrappedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('${AppConfig.baseUrl}/user/myscrap?userID=$userID');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          scrapedPosts = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print('스크랩 목록 실패: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('스크랩 목록 오류: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스크랩한 글')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : scrapedPosts.isEmpty
          ? Center(child: Text('스크랩한 글이 없습니다.'))
          : ListView.builder(
        itemCount: scrapedPosts.length,
        itemBuilder: (context, index) {
          final post = scrapedPosts[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['subject'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(post['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.bookmark_remove),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userID = prefs.getInt('userID');
                      final postId = post['id'];
                      final url = Uri.parse('${AppConfig.baseUrl}/question/scrap/$postId?userID=$userID');
                      try {
                        final response = await http.post(url);
                        if (response.statusCode == 200) {
                          setState(() {
                            scrapedPosts.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('스크랩이 해제되었습니다.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('스크랩 해제 실패: ${response.statusCode}')),
                          );
                        }
                      } catch (e) {
                        print('스크랩 해제 오류: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('스크랩 해제 중 오류 발생')),
                        );
                      }
                    },
                  ),
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${(post['voter'] as List?)?.length ?? 0}'),
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
