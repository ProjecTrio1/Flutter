import 'package:flutter/material.dart';
import 'post_detail.dart';

final List<Map<String, dynamic>> scrapedPosts = [];

class GroupScrapScreen extends StatelessWidget {
  const GroupScrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스크랩한 글')),
      body: scrapedPosts.isEmpty
          ? Center(child: Text('스크랩한 글이 없습니다.'))
          : ListView.builder(
        itemCount: scrapedPosts.length,
        itemBuilder: (context, index) {
          final post = scrapedPosts[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(post['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 16),
                  SizedBox(width: 4),
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
