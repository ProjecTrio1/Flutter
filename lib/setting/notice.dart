import 'package:flutter/material.dart';
import '../config.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  List<bool> _expanded = [false, false];

  final List<Map<String, String>> notices = [
    {
      'title': 'AI 소비 패턴 분석 업데이트',
      'content': '새로운 AI 분석 기능이 적용되었습니다. 이제 더 정확한 소비 습관 분석이 가능합니다.'
    },
    {
      'title': '정기 지출 알림 기능 추가',
      'content': '정기 지출을 등록하면 한 달 후 다시 알림을 받을 수 있는 기능이 추가되었습니다.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('공지사항')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          final isOpen = _expanded[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(notice['title']!, style: NoteTextStyles.subHeader)),
                        IconButton(
                          icon: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _expanded[index] = !_expanded[index];
                            });
                          },
                        )
                      ],
                    ),
                    if (isOpen)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(notice['content']!, style: NoteTextStyles.subtitle),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
