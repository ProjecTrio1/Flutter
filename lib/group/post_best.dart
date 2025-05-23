
import 'package:flutter/material.dart';
import '../config.dart';
import 'post_detail.dart';
import 'group_home.dart'; // dummyPosts 불러오기 위해

class GroupBestScreen extends StatefulWidget {
  @override
  _GroupBestScreenState createState() => _GroupBestScreenState();
}

class _GroupBestScreenState extends State<GroupBestScreen> {
  String _sortMode = 'recommend'; // 'recommend' 또는 'recent'

  List<Map<String, dynamic>> get _filteredPosts {
    final filtered = dummyPosts.where((p) => (p['likes'] ?? 0) >= 10).toList();
    if (_sortMode == 'recommend') {
      filtered.sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));
    }
    return filtered;
  }
  // todo: 10개 이상 올라감
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('베스트 글'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortMode = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'recommend', child: Text('추천순')),
              PopupMenuItem(value: 'recent', child: Text('최신순')),
            ],
            icon: Icon(Icons.sort),
            tooltip: '정렬 방식',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) {
          final post = _filteredPosts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(post['content']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  Text('${post['likes']}'),
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
