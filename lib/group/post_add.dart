import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GroupPostAddScreen extends StatefulWidget {
  @override
  _GroupPostAddScreenState createState() => _GroupPostAddScreenState();
}

class _GroupPostAddScreenState extends State<GroupPostAddScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
  File? _selectedImage;

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

    // TODO: API 연동 또는 상태에 추가 로직
    print('제목: $title');
    print('내용: $content');
    print('익명 여부: $_isAnonymous');
    print('이미지 선택됨: ${_selectedImage != null}');

    Navigator.pop(context); // 등록 후 이전 화면으로
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text('등록', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 내용 입력
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),

            // 이미지 추가
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('미디어 추가'),
                ),
                SizedBox(width: 12),
                if (_selectedImage != null)
                  Expanded(
                    child: Text(
                      _selectedImage!.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // 익명 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('익명으로 작성'),
                Switch(
                  value: _isAnonymous,
                  onChanged: (val) {
                    setState(() {
                      _isAnonymous = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
