import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteListScreen extends StatefulWidget {
  final int year;
  final int month;

  const NoteListScreen({Key? key, required this.year, required this.month}) : super(key: key);

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  Map<DateTime, List<Map<String, dynamic>>> _groupedNotes = {};
  int _monthlyIncome = 0;
  int _monthlyExpense = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotesForList(widget.year, widget.month);
  }

  DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _fetchNotesForList(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('http://10.0.2.2:8080/note/list?userID=$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> notes = jsonDecode(utf8.decode(response.bodyBytes));
      Map<DateTime, List<Map<String, dynamic>>> grouped = {};
      int income = 0;
      int expense = 0;

      for (var note in notes) {
        final raw = note['createdAt']?.toString();
        if (raw == null) continue;

        final date = DateTime.parse(raw).toLocal();
        if (date.year == year && date.month == month) {
          final key = normalizeDate(date);
          grouped.putIfAbsent(key, () => []).add(note);

          final amount = note['amount'];
          final isIncome = note['isIncome'];
          if (amount != null) {
            if (isIncome == true) income += amount as int;
            else expense += amount as int;
          }
        }
      }

      setState(() {
        _groupedNotes = grouped;
        _monthlyIncome = income;
        _monthlyExpense = expense;
      });
    }
  }

  Widget _buildSummaryBox(String label, int amount, Color color) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text('${formatter.format(amount)}원', style: TextStyle(color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    final formatter = NumberFormat('#,###');
    final time = DateFormat('HH:mm').format(DateTime.parse(note['createdAt']).toLocal());
    final isIncome = note['isIncome'] ?? false;
    final amount = note['amount'] ?? 0;
    final category = note['category'] ?? '';
    final content = note['content'] ?? '';
    final memo = note['memo'] ?? '';

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category, style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(content, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              if (memo.isNotEmpty) Text(memo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatter.format(amount)}원',
            style: TextStyle(color: isIncome ? Colors.blue : Colors.red, fontSize: 15),
          )
        ],
      ),
      subtitle: Text(time, style: TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _groupedNotes.keys.toList()..sort((a, b) => b.compareTo(a));
    final formatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final notes = _groupedNotes[date] ?? [];
              final net = notes.fold<int>(0, (sum, e) {
                final amount = (e['amount'] ?? 0) as num;
                return sum + ((e['isIncome'] ?? false) ? amount.toInt() : -amount.toInt());
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('M월 d일 (E)', 'ko_KR').format(date),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                          '${net >= 0 ? '+' : '-'}${formatter.format(net.abs())}원',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ...notes.map((note) => _buildNoteItem(note)).toList(),
                  Divider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
