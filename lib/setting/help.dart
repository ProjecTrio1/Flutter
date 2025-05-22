import 'package:flutter/material.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  List<bool> _expanded = [false, false];

  final List<Map<String, String>> helpItems = [
    {
      'question': '지출 알림은 어떻게 설정하나요?',
      'answer': '가계부 작성 화면에서 "한 달 후 과소비 확인 알림"을 켜면 설정됩니다.'
    },
    {
      'question': '카테고리를 수정하거나 한도를 설정하고 싶어요.',
      'answer': '마이페이지 > 카테고리 수정 / 한도 설정 메뉴에서 관리할 수 있습니다.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('도움말')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          final item = helpItems[index];
          final isOpen = _expanded[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item['question']!, style: NoteTextStyles.subHeader)),
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
                        child: Text(item['answer']!, style: NoteTextStyles.subtitle),
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
