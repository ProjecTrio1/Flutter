import 'package:flutter/material.dart';
import 'post_add.dart';
import 'post_scrap.dart';

class GroupPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const GroupPostDetailScreen({super.key, required this.post});

  @override
  State<GroupPostDetailScreen> createState() => _GroupPostDetailScreenState();
}

class _GroupPostDetailScreenState extends State<GroupPostDetailScreen> {
  late Map<String, dynamic> post;
  int likes = 0;
  int scraps = 0;
  bool likedPost = false;
  bool isScrapped = false;

  List<Map<String, dynamic>> comments = [];
  Set<int> likedCommentIndexes = {};
  Set<String> likedReplyIds = {};
  int? replyingToIndex;

  final TextEditingController _commentController = TextEditingController();
  final String currentUserEmail = 'admin1@gmail.com'; // 예시 사용자

  @override
  void initState() {
    super.initState();
    post = Map.from(widget.post);
    likes = post['likes'] ?? 0;
    scraps = post['scraps'] ?? 0;
    comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final newComment = {
      'content': content,
      'author': currentUserEmail,
      'date': '05/16 23:45',
      'likes': 0,
      'replies': [],
    };

    setState(() {
      if (replyingToIndex != null) {
        comments[replyingToIndex!]['replies'] ??= [];
        comments[replyingToIndex!]['replies'].add(newComment);
        replyingToIndex = null;
      } else {
        comments.add(newComment);
      }
    });

    _commentController.clear();
  }

  void toggleScrap() {
    setState(() {
      isScrapped = true;
      scraps++;
      if (!scrapedPosts.contains(post)) {
        scrapedPosts.add(post);
      }
    });
  }

  void _editPost() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => GroupPostAddScreen(existingPost: post),
      ),
    );
    if (updated != null) {
      setState(() {
        post = updated;
      });
    }
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('게시글 삭제'),
        content: Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 뒤로 이동
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAuthorEmail = post['author'] ?? '';
    final postDate = post['date'] ?? '날짜 없음';

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
        actions: [
          IconButton(
            icon: Icon(
              isScrapped ? Icons.bookmark : Icons.bookmark_border,
              color: isScrapped ? Colors.orange : null,
            ),
            tooltip: '스크랩',
            onPressed: isScrapped
                ? null
                : () {
              toggleScrap();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('스크랩되었습니다.')),
              );
            },
          ),
          if (postAuthorEmail == currentUserEmail)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editPost();
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: _buildPostContent(postAuthorEmail, postDate),
    );
  }

  Widget _buildPostContent(String postAuthorEmail, String postDate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post['title'] ?? '제목 없음',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('익명 | $postDate', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          Text(post['content'] ?? '', style: TextStyle(fontSize: 16)),
          SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                icon: Icon(likedPost ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                onPressed: likedPost
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미 추천하셨습니다.')),
                  );
                }
                    : () {
                  setState(() {
                    likes++;
                    likedPost = true;
                  });
                },
              ),
              Text('$likes'),
              SizedBox(width: 16),
              Icon(Icons.comment, size: 20),
              SizedBox(width: 4),
              Text('${comments.length}')
            ],
          ),
          Divider(height: 32),
          _buildCommentList(postAuthorEmail),
          Divider(),
          if (replyingToIndex != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('대댓글 작성 중'),
                TextButton(
                  onPressed: () => setState(() => replyingToIndex = null),
                  child: Text('취소'),
                ),
              ],
            ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: replyingToIndex == null ? '댓글을 입력하세요' : '대댓글을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitComment,
              child: Text('등록'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(String postAuthorEmail) {
    return Expanded(
      child: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          final commentAuthorEmail = comment['author'] ?? '';
          final isAuthor = commentAuthorEmail == postAuthorEmail;
          final commentDisplayName = isAuthor ? '익명 (작성자)' : '익명';
          final commentDate = comment['date'] ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(comment['content'] ?? ''),
                subtitle: Text('$commentDisplayName | $commentDate'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        likedCommentIndexes.contains(index)
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 16,
                      ),
                      onPressed: likedCommentIndexes.contains(index)
                          ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 추천하셨습니다.')),
                        );
                      }
                          : () {
                        setState(() {
                          comment['likes'] = (comment['likes'] ?? 0) + 1;
                          likedCommentIndexes.add(index);
                        });
                      },
                    ),
                    SizedBox(width: 4),
                    Text('${comment['likes'] ?? 0}'),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'reply') {
                          setState(() => replyingToIndex = index);
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('댓글 삭제'),
                              content: Text('정말 삭제하시겠습니까?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
                                TextButton(
                                  onPressed: () {
                                    setState(() => comments.removeAt(index));
                                    Navigator.pop(context);
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'reply', child: Text('대댓글 달기')),
                        if (comment['author'] == currentUserEmail)
                          PopupMenuItem(value: 'delete', child: Text('삭제')),
                      ],
                    ),
                  ],
                ),
              ),
              ...(comment['replies'] ?? []).asMap().entries.map((entry) {
                final reply = entry.value;
                final isReplyAuthor = reply['author'] == postAuthorEmail;
                final replyDisplay = isReplyAuthor ? '익명 (작성자)' : '익명';
                final replyKey = '$index-${entry.key}';

                return Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: ListTile(
                    title: Text(reply['content'] ?? ''),
                    subtitle: Text('$replyDisplay | ${reply['date'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            likedReplyIds.contains(replyKey)
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 16,
                          ),
                          onPressed: likedReplyIds.contains(replyKey)
                              ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('이미 추천하셨습니다.')),
                            );
                          }
                              : () {
                            setState(() {
                              reply['likes'] = (reply['likes'] ?? 0) + 1;
                              likedReplyIds.add(replyKey);
                            });
                          },
                        ),
                        SizedBox(width: 4),
                        Text('${reply['likes'] ?? 0}'),
                        if (reply['author'] == currentUserEmail)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('대댓글 삭제'),
                                    content: Text('정말 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            comments[index]['replies'].removeAt(entry.key);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'delete', child: Text('삭제')),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
