import 'package:flutter/material.dart';
import '../config.dart';
import 'package:intl/intl.dart';
import '../style/note_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../setting/reminder_manager.dart';

class OverspendFeedbackDialog extends StatefulWidget {
  final Map<String, String> reminder;
  const OverspendFeedbackDialog({required this.reminder, super.key});

  @override
  State<OverspendFeedbackDialog> createState() => _OverspendFeedbackDialogState();
}

class _OverspendFeedbackDialogState extends State<OverspendFeedbackDialog> {
  bool? _selectedFeedback; // true=좋아요, false=싫어요, null=미선택

  @override
  Widget build(BuildContext context) {
    final content = widget.reminder['content'] ?? '';
    final amount = widget.reminder['amount'] ?? '';
    final id = widget.reminder['id'] ?? '';

    return AlertDialog(
      title: const Text('과소비 피드백', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$content \n금액: $amount원\n이 소비에 대한 피드백을 남겨주세요.'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.thumb_up,
                  color: _selectedFeedback == true ? NoteColors.income : Colors.grey,
                ),
                onPressed: () {
                  setState(() => _selectedFeedback = _selectedFeedback == true ? null : true);
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.thumb_down,
                  color: _selectedFeedback == false ? NoteColors.expense : Colors.grey,
                ),
                onPressed: () {
                  setState(() => _selectedFeedback = _selectedFeedback == false ? null : false);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            if (_selectedFeedback != null) {
              await _sendFeedback(id, _selectedFeedback!);
              await ReminderManager.deleteReminderItem(id);
              if (context.mounted) Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('피드백을 선택해주세요')),
              );
            }
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  Future<void> _sendFeedback(String id, bool agree) async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/note/report/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'noteId': int.tryParse(id), 'agree': agree}),
      );
    } catch (_) {
      print("서버 피드백 전송 실패");
    }
  }
}
