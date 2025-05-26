import 'package:flutter/material.dart';
import '../config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/http_helper.dart';

class GroupPostAddScreen extends StatefulWidget {
  final Map<String, dynamic>? existingPost;

  const GroupPostAddScreen({super.key, this.existingPost});

  @override
  _GroupPostAddScreenState createState() => _GroupPostAddScreenState();
}

class _GroupPostAddScreenState extends State<GroupPostAddScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;

  final bool _isAnonymous = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      _titleController.text = widget.existingPost!['subject'] ?? '';
      _contentController.text = widget.existingPost!['content'] ?? '';
    }
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    print('보낼 userID: $userID');

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    try {
      final body = jsonEncode({'subject': title, 'content': content});

      late final http.Response response;
      if (widget.existingPost != null && widget.existingPost!['id'] != null) {
        // 수정 요청
        final id = widget.existingPost!['id'];
        response = await HttpClientWithCookies.post(
          Uri.parse('${AppConfig.baseUrl}/question/modify/$id?userID=$userID'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

      } else {
        // 새 글 등록
        response = await HttpClientWithCookies.post(
          Uri.parse('${AppConfig.baseUrl}/question/create?userID=$userID'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, {
          'refresh': true,
          'post': {
            'id': widget.existingPost?['id'],
            'subject': title,
            'content': content,
            'author': widget.existingPost?['author'],
            'createDate': widget.existingPost?['createDate'],}
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('요청 실패 (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('에러 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 중 오류가 발생했습니다')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPost != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '게시글 수정' : '글쓰기'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text('등록', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: '내용',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    _selectedImage != null ? '미디어 변경' : '미디어 추가',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
