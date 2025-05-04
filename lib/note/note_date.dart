//달력에서 날짜 선택 시 이동하는 페이지

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteDateScreen extends StatefulWidget {
  final DateTime selectedDate;

  const NoteDateScreen({required this.selectedDate});

  @override
  State<NoteDateScreen> createState() => _NoteDateScreenState();
}

class _NoteDateScreenState extends State<NoteDateScreen> {
  List<Map<String, dynamic>> _notes = [];
  int _totalIncome = 0;
  int _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotesForDate();
  }

  Future<void> _fetchNotesForDate() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');

    final url = Uri.parse('http://10.0.2.2:8080/note/list?userID=$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> notes = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> filtered = [];

      int income = 0;
      int expense = 0;

      for (var note in notes) {
        final dateStr = note['createdAt']?.toString();
        if (dateStr == null) continue;

        final date = DateTime.parse(dateStr).toLocal();
        final isSameDay = date.year == widget.selectedDate.year &&
            date.month == widget.selectedDate.month &&
            date.day == widget.selectedDate.day;

        if (isSameDay) {
          final item = note as Map<String, dynamic>;
          filtered.add(item);

          final amount = item['amount'] ?? 0;
          if (item['isIncome'] == true) {
            income += amount as int;
          } else {
            expense += amount as int;
          }
        }
      }

      setState(() {
        _notes = filtered;
        _totalIncome = income;
        _totalExpense = expense;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 요약 박스
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('총수입', _totalIncome, Colors.blue),
                  SizedBox(height: 6),
                  _buildSummaryRow('총지출', _totalExpense, Colors.red),
                  SizedBox(height: 6),
                  _buildSummaryRow(
                    '합계',
                    _totalIncome - _totalExpense,
                    (_totalIncome - _totalExpense) >= 0 ? Colors.black : Colors.red,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 항목 리스트
            Expanded(
              child: _notes.isEmpty
                  ? Center(child: Text("내역이 없습니다"))
                  : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final item = _notes[index];
                  final isIncome = item['isIncome'] == true;
                  final category = item['category'] ?? '';
                  final content = item['content'] ?? '';
                  final memo = item['memo'] ?? '';
                  final amount = item['amount'] ?? 0;
                  final date = DateTime.parse(item['createdAt']).toLocal();
                  final timeStr = timeFormat.format(date);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category, style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(content, style: TextStyle(fontSize: 16)),
                              Text(
                                '${isIncome ? "+" : "-"}${formatter.format(amount)}원',
                                style: TextStyle(
                                  color: isIncome ? Colors.blue : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          if (memo != '')
                            Text(memo, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(timeStr, style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, Color color) {
    final formatter = NumberFormat('#,###');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text('${formatter.format(amount)}원', style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }
}
