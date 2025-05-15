import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final String currentUserEmail = 'admin1@gmail.com'; // 로그인 사용자 가정

  @override
  void initState() {
    super.initState();

    if (widget.existingPost != null) {
      _titleController.text = widget.existingPost!['title'] ?? '';
      _contentController.text = widget.existingPost!['content'] ?? '';
      // todo: 아직 이미지 테스트를 못함..
      // _selectedImage = File(widget.existingPost!['imagePath']);
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

  void _submitPost() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    final post = {
      'title': title,
      'content': content,
      'author': currentUserEmail,
      'anonymous': _isAnonymous,
      'likes': widget.existingPost?['likes'] ?? 0,
      'scraps': widget.existingPost?['scraps'] ?? 0,
      'date': widget.existingPost?['date'] ?? '05/16 23:45',
      'comments': widget.existingPost?['comments'] ?? [],
    };

    Navigator.pop(context, post);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text(_selectedImage != null ? '미디어 변경' : '미디어 추가'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }
}
