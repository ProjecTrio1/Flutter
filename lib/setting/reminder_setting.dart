import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../style/main_style.dart';
import '../style/note_style.dart';
import 'reminder_manager.dart';
import 'package:http/http.dart' as http;

class ReminderSettingScreen extends StatefulWidget {
  const ReminderSettingScreen({Key? key}) : super(key: key);

  @override
  State<ReminderSettingScreen> createState() => _ReminderSettingScreenState();
}

class _ReminderSettingScreenState extends State<ReminderSettingScreen> {
  List<Map<String, String>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final items = await ReminderManager.loadReminderItems();
    final now = DateTime.now();

    final validItems = <Map<String, String>>[];
    for (var item in items) {
      final createdAt = DateTime.tryParse(item['createdAt'] ?? '') ?? now;
      if (now.difference(createdAt).inDays < 30) {
        validItems.add(item);
      } else {
        if (item['id'] != null) await ReminderManager.deleteReminderItem(item['id']!);
      }
    }

    validItems.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? now;
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? now;
      return aDate.compareTo(bDate);
    });

    setState(() {
      _reminders = validItems;
    });
  }

  Future<void> _deleteReminder(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text('이 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('삭제')),
        ],
      ),
    );
    if (confirm == true) {
      await ReminderManager.deleteReminderItem(id);
      await ReminderManager.markOverspendAsFalse(id);
      _loadReminders();
    }
  }

  Future<void> _sendFeedbackToServer(String id, bool agree) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/note/report/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'noteId': id, 'agree': agree}),
      );

      if (response.statusCode == 200) {
        print('피드백 전송 성공');
      } else {
        print('피드백 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
    }
  }

  Future<void> _toggleFeedback(String id, bool agree) async {
    setState(() {
      _reminders = _reminders.map((e) {
        if (e['id'] == id) {
          final current = e['feedback'];
          if ((agree && current == 'up') || (!agree && current == 'down')) {
            _sendFeedbackToServer(id, false); // 취소 처리
            return {...e, 'feedback': ''};
          } else {
            _sendFeedbackToServer(id, agree);
            return {...e, 'feedback': agree ? 'up' : 'down'};
          }
        }
        return e;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('저장된 알림 목록')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _reminders.isEmpty
            ? Center(child: Text('설정된 알림이 없습니다.', style: NoteTextStyles.subtitle))
            : ListView.builder(
          itemCount: _reminders.length,
          itemBuilder: (context, index) {
            final item = _reminders[index];
            final dateStr = item['createdAt'] != null
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['createdAt']!))
                : '날짜 없음';
            final feedback = item['feedback'];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['content'] ?? '알 수 없음', style: NoteTextStyles.subHeader),
                              SizedBox(height: 4),
                              Text(
                                '카테고리: ${item['category']} | 금액: ${item['amount']}원\n등록일: $dateStr',
                                style: NoteTextStyles.subtitle,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(item['id'] ?? ''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _toggleFeedback(item['id'] ?? '', true),
                          icon: Icon(
                            Icons.thumb_up,
                            color: feedback == 'up' ? NoteColors.income : Colors.grey.shade400,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleFeedback(item['id'] ?? '', false),
                          icon: Icon(
                            Icons.thumb_down,
                            color: feedback == 'down' ? NoteColors.expense : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}