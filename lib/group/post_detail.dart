import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'post_add.dart';
import '../style/main_style.dart';

class GroupPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const GroupPostDetailScreen({super.key, required this.post});

  @override
  State<GroupPostDetailScreen> createState() => _GroupPostDetailScreenState();
}

class _GroupPostDetailScreenState extends State<GroupPostDetailScreen> {
  Set<int> likedCommentIndexes = {};
  late Map<String, dynamic> post;
  List<Map<String, dynamic>> comments = [];
  String? currentUserEmail;
  final TextEditingController _commentController = TextEditingController();
  bool likedPost = false;
  bool isScrapped = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();
    post = Map.from(widget.post);
    likes = (post['voter'] as List?)?.length ?? 0;
    _loadUserEmail().then((_) async {
      await _fetchPostDetail();
      _checkIfScrapped();
      _fetchComments();
    });
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('email');
    });
  }

  Future<void> _fetchPostDetail() async {
    final postId = post['id'];
    final url = Uri.parse('${AppConfig.baseUrl}/question/detail/$postId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          post = data;
          likes = (post['voter'] as List?)?.length ?? 0;
        });
        await _checkIfVoted();
      } else {
        print('게시글 상세 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('게시글 상세 불러오기 오류: $e');
    }
  }

  Future<void> _fetchComments() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final postId = post['id'];
    final url = Uri.parse('${AppConfig.baseUrl}/answer/list/$postId?userID=$userID');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print('댓글: ${jsonEncode(data)}');
        setState(() {
          comments = data.cast<Map<String, dynamic>>();
        });
      } else {
        print('댓글 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('댓글 불러오기 오류: $e');
    }
  }

  Future<void> _submitComment() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final postId = post['id'];
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final url = Uri.parse('${AppConfig.baseUrl}/answer/create/$postId?userID=$userID');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();
        await _fetchComments();
      } else {
        print('댓글 등록 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('댓글 등록 오류: $e');
    }
  }

  Future<void> _checkIfScrapped() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final postId = post['id'];
    final url = Uri.parse('${AppConfig.baseUrl}/user/myscrap?userID=$userID');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final scrappedIds = data.map((e) => e['id']).toSet();
        setState(() {
          isScrapped = scrappedIds.contains(postId);
        });
      }
    } catch (e) {
      print('스크랩 상태 확인 실패: $e');
    }
  }

  Future<void> _votePost() async {
    if (likedPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 추천한 게시글입니다.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final postId = post['id'];
    final url = Uri.parse('${AppConfig.baseUrl}/question/vote/$postId?userID=$userID');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        await _fetchPostDetail();

        setState(() {
          likedPost = true;
          likes = post['likes'] ?? likes;
        });
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 추천한 게시글입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 추천 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('추천 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 추천 중 오류 발생')),
      );
    }
  }


  Future<void> _voteComment(int commentId) async {
    if (likedCommentIndexes.contains(commentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 추천한 댓글입니다.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('${AppConfig.baseUrl}/answer/vote/$commentId?userID=$userID');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        likedCommentIndexes.add(commentId);
        await _fetchComments();
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 추천한 댓글입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 추천 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('댓글 추천 예외: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 추천 중 오류 발생')),
      );
    }
  }

  void _editComment(BuildContext context, Map<String, dynamic> comment) {
    final TextEditingController _editController =
    TextEditingController(text: comment['content'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('댓글 수정'),
        content: TextField(
          controller: _editController,
          maxLines: null,
          decoration: InputDecoration(
            hintText: '수정할 내용을 입력하세요',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          TextButton(
            onPressed: () async {
              final updatedContent = _editController.text.trim();
              if (updatedContent.isNotEmpty) {
                final url = Uri.parse('${AppConfig.baseUrl}/answer/modify/${comment['id']}');
                final response = await http.put(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'content': updatedContent}),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  await _fetchComments();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                  );
                }
              }
            },
            child: Text('수정'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('댓글 삭제'),
        content: Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('확인')),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getInt('userID');

      final url = Uri.parse('${AppConfig.baseUrl}/answer/delete/$commentId?userID=$userID');
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchComments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글이 삭제되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: ${response.statusCode}')),
        );
      }
    }
  }

  Future<void> _toggleScrap() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final postId = post['id'];
    final url = Uri.parse('${AppConfig.baseUrl}/question/scrap/$postId?userID=$userID');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final message = utf8.decode(response.bodyBytes);
        final added = message.contains('스크랩되었습니다');
        setState(() {
          isScrapped = added;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('스크랩 실패')));
      }
    } catch (e) {
      print('스크랩 예외: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('스크랩 중 오류 발생')));
    }
  }

  Future<void> _checkIfVoted() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final voterList = (post['voter'] as List?) ?? [];

    setState(() {
      likedPost = voterList.any((voter) {
        final voterId = voter['id'];
        return voterId is int ? voterId == userID : voterId.toString() == userID.toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final postEmail = post['author']?['email'] ?? '';
    final postDate = post['createDate'] ?? '';
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('게시글 상세'),
        actions: [
          IconButton(
            icon: Icon(
              isScrapped ? Icons.bookmark : Icons.bookmark_border,
              color: isScrapped ? AppColors.primary : null,
            ),
            tooltip: '스크랩',
            onPressed: _toggleScrap,
          ),
          if (currentUserEmail == postEmail)
            PopupMenuButton<String>(
              onSelected: (value) async {
                print('넘겨주는 post: ${post}');
                if (value == 'edit') {
                  final updated = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupPostAddScreen(existingPost: post),
                    ),
                  );
                  if (updated != null) {
                    setState(() => post = updated);
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('게시글 삭제'),
                      content: Text('정말 삭제하시겠습니까?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('확인')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final prefs = await SharedPreferences.getInstance();
                    final userID = prefs.getInt('userID');

                    final res = await http.get(
                      Uri.parse('${AppConfig.baseUrl}/question/delete/${post['id']}?userID=$userID'),
                    );

                    if (res.statusCode == 200 || res.statusCode == 204) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 완료')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: ${res.statusCode}')));
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(post['subject'] ?? '제목 없음',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Text('익명 | ${formatter.format(DateTime.parse(postDate))}', style: TextStyle(
              fontSize: 12, color: Colors.grey)),
          SizedBox(height: 20),
          Text(post['content'] ?? '', style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(likedPost ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  color: likedPost ? AppColors.primary : null, size: 22,),
                onPressed: _votePost,
              ),
              Text('$likes'),
            ],
          ),
          Divider(height: 32),
          Text('댓글 ${comments.length}', style: TextStyle(fontWeight: FontWeight.bold)),
          ...comments.map((comment) {
            final commentId = comment['id'];
            final isAuthor = comment['author']?['email'] == post['author']?['email'];
            final displayName = isAuthor ? '익명 (작성자)' : '익명';
            final content = comment['content'] ?? '';
            final rawDate = comment['createDate']?.toString();
            final date = rawDate != null ? formatter.format(DateTime.parse(rawDate)) : '';
            final voterList = comment['voter'] as List?;
            final likes = voterList?.length ?? 0;

            return FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox.shrink();
                final userId = snapshot.data!.getInt('userID');
                final hasVoted = voterList?.any((v) => v['id'] == userId) ?? false;

                return GestureDetector(
                  onLongPress: () {
                    if (comment['author']?['email'] == currentUserEmail) {
                      _deleteComment(commentId);
                    }
                  },
                  child: ListTile(
                    title: Text(content),
                    subtitle: Text('$displayName | $date'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            hasVoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                            size: 18,
                            color: hasVoted ? AppColors.primary : null,
                          ),
                          onPressed: () => _voteComment(commentId),
                        ),
                        SizedBox(width: 0),
                        Text('$likes'),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: '댓글 입력',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _submitComment,
              ),
            ),
          ),
        ),
      ),


    );
  }
}
