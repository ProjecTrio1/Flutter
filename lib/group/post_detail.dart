
import 'package:flutter/material.dart';

class GroupPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const GroupPostDetailScreen({super.key, required this.post});

  @override
  State<GroupPostDetailScreen> createState() => _GroupPostDetailScreenState();
}

class _GroupPostDetailScreenState extends State<GroupPostDetailScreen> {
  int likes = 0;
  int scraps = 0;
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    likes = widget.post['likes'] ?? 0;
    scraps = widget.post['scraps'] ?? 0;
    comments = List<Map<String, dynamic>>.from(widget.post['comments'] ?? []);
  }

  void toggleLike() => setState(() => likes++);
  void toggleScrap() => setState(() => scraps++);

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final bool isAnonymous = post['anonymous'] ?? false;
    final String author = isAnonymous ? '익명' : (post['author'] ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border),
            tooltip: '스크랩',
            onPressed: toggleScrap,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['title'] ?? '제목 없음',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('$author | ${post['date'] ?? '날짜 없음'}',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Text(post['content'] ?? '', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Row(
              children: [
                IconButton(icon: Icon(Icons.thumb_up_alt_outlined), onPressed: toggleLike),
                Text('$likes'),
                SizedBox(width: 16),
                Icon(Icons.comment, size: 20),
                SizedBox(width: 4),
                Text('${comments.length}')
              ],
            ),
            Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final commentAuthor = comment['anonymous'] == true
                      ? '익명'
                      : (comment['author'] ?? '');
                  return ListTile(
                    title: Text(comment['content'] ?? ''),
                    subtitle: Text('$commentAuthor | ${comment['date'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up, size: 16),
                        SizedBox(width: 4),
                        Text('${comment['likes'] ?? 0}'),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
