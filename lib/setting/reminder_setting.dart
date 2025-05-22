import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';
import 'reminder_manager.dart';

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
    setState(() {
      _reminders = items;
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
      _loadReminders();
    }
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(item['content'] ?? '알 수 없음', style: NoteTextStyles.subHeader),
                subtitle: Text(
                  '카테고리: ${item['category']} | 금액: ${item['amount']}원\n등록일: $dateStr',
                  style: NoteTextStyles.subtitle,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReminder(item['id'] ?? ''),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
