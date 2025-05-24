import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../style/main_style.dart';
import '../style/note_style.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({Key? key}) : super(key: key);

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('alert_')).toList();
    keys.sort((a, b) => b.compareTo(a)); // 최신순

    final items = <Map<String, dynamic>>[];
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr);
        if (map is Map<String, dynamic>) {
          items.add(map);
        }
      }
    }

    setState(() => _notifications = items);
  }

  Future<void> _deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alert_$id');
    _loadNotifications();
  }

  Future<void> _pinNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('alert_$id');
    if (data != null) {
      final map = jsonDecode(data);
      map['pinned'] = true;
      await prefs.setString('alert_$id', jsonEncode(map));
      _loadNotifications();
    }
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('alert_')).toList();

    for (final k in keys) {
      final jsonStr = prefs.getString(k);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr);
        if (map is Map && map['pinned'] != true) {
          await prefs.remove(k);
        }
      }
    }
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(' 알림', style: AppTextStyles.title),
                Spacer(),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearAll,
                  child: Text('전체 삭제', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(child: Text('알림이 없습니다.', style: AppTextStyles.body))
                  : ListView.builder(
                controller: controller,
                itemCount: _notifications.length,
                itemBuilder: (_, index) {
                  final item = _notifications[index];
                  final id = item['id'];
                  final isPinned = item['pinned'] == true;

                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      setState(() {
                        _notifications.removeAt(index);
                      });

                      if (direction == DismissDirection.endToStart) {
                        _deleteNotification(id);
                      } else if (direction == DismissDirection.startToEnd) {
                        _pinNotification(id);
                      }
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: NoteColors.income,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.push_pin, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.redAccent,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPinned ? AppColors.primary : AppColors.borderGray,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            style: AppTextStyles.bold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['body'] ?? '',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
