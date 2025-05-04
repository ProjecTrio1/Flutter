import 'package:flutter/material.dart';
import 'post_best.dart';
import 'post_add.dart';
import 'post_detail.dart';

//예시 데이터
final List<Map<String, dynamic>> dummyPosts = [
  {
    'title': '제목1',
    'content': '길게길게 길게길게길게길게길게길게길게길게길게길게길게길게'
        '길게길게길게길게길게길게길게길게길게길게길게길게길게길게길게길게',
    'author': 'admin1@gmail.com',
    'likes': 5,
    'scraps': 2,
    'date': '05/04 18:45',
    'anonymous': true,
    'comments': [
      {
        'content': '댓글',
        'author': 'user1@gmail.com',
        'likes': 1,
        'date': '05/04 18:50',
        'anonymous': false,
      },
      {
        'content': '댓글2',
        'author': 'user2@gmail.com',
        'likes': 0,
        'date': '05/04 19:10',
        'anonymous': true,
      },
    ],
  },
  {
    'title': '제목2',
    'content': '짧게',
    'author': 'test1@gmail.com',
    'likes': 12,
    'scraps': 1,
    'date': '05/04 15:00',
    'anonymous': false,
    'comments': [],
  },
];


class GroupHomeScreen extends StatelessWidget {
  final String username;
  final int userID;
  final String groupName;

  const GroupHomeScreen({
    super.key,
    required this.username,
    required this.userID,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('$groupName 커뮤니티'),
            SizedBox(width: 8),
            Tooltip(
              message: '소비패턴 어쩌구? 설명',
              child: Icon(Icons.help_outline, size: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border),
            tooltip: '베스트 글',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupBestScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/group/scrap');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text('작성자: ${post['author']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${post['likes']}'),
                  SizedBox(width: 8),
                  Icon(Icons.comment, size: 16),
                  SizedBox(width: 4),
                  Text('${post['comments'].length}'),
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
        onPressed: () {
          Navigator.pushNamed(context, '/group/add');
        },
        child: Icon(Icons.edit),
        tooltip: '글쓰기',
      ),
    );
  }
}
