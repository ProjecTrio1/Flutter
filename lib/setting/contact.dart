import 'package:flutter/material.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submitInquiry() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')));
      return;
    }

    // 향후 서버 전송 로직 작성 위치

    _titleController.clear();
    _contentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('문의가 임시 저장되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('문의하기')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목', style: NoteTextStyles.subHeader),
            SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text('내용', style: NoteTextStyles.subHeader),
            SizedBox(height: 4),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '문의 내용을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.image, color: AppColors.primary),
                SizedBox(width: 5),
                Text('미디어 추가', style: TextStyle(color: AppColors.primary)),
              ],
            ),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('문의 메일: projectrio@xxxxx.com',
                  style: NoteTextStyles.subtitle.copyWith(color: Colors.grey.shade700)),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitInquiry,
                child: Text('문의 제출'),
                style: NoteDecorations.filledButton,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
