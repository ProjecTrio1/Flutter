import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'note_date.dart';
import 'note_list_widget.dart';
import '../style/note_style.dart';
import '../style/main_style.dart';
import 'note_add.dart';

class NoteMonthScreen extends StatefulWidget {
  @override
  State<NoteMonthScreen> createState() => _NoteMonthScreenState();
}

class _NoteMonthScreenState extends State<NoteMonthScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  Map<DateTime, List<Map<String, dynamic>>> _groupedNotes = {};
  int _monthlyIncome = 0;
  int _monthlyExpense = 0;
  bool isCalendarView = true;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyNotes();
  }

  DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _fetchMonthlyNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    if (userID == null) return;

    final url = Uri.parse('${AppConfig.baseUrl}/note/list?userID=$userID');
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
        if (date.year == _selectedYear && date.month == _selectedMonth) {
          final key = normalizeDate(date);
          grouped.putIfAbsent(key, () => []).add(note);

          final amount = int.tryParse(note['amount'].toString()) ?? 0;
          final isIncome = note['isIncome'] == true;
          if (isIncome) income += amount;
          else expense += amount;
        }
      }

      setState(() {
        _groupedNotes = grouped;
        _monthlyIncome = income;
        _monthlyExpense = expense;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = normalizeDate(day);
    return _groupedNotes[key] ?? [];
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDateScreen(selectedDate: selected),
      ),
    ).then((_) => _fetchMonthlyNotes()); // 돌아올 때 데이터 반영
  }

  void _toggleView() {
    setState(() {
      isCalendarView = !isCalendarView;
    });
  }

  void _showMonthSelector() async {
    int tempYear = _selectedYear;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: () => setStateDialog(() => tempYear--),
                        ),
                        Text('$tempYear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () => setStateDialog(() => tempYear++),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      children: List.generate(12, (i) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedYear = tempYear;
                              _selectedMonth = i + 1;
                              _focusedDay = DateTime(_selectedYear, _selectedMonth, 1);
                              _selectedDay = null;
                            });
                            _fetchMonthlyNotes();
                          },
                          child: Text('${i + 1}월'),
                        );
                      }),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNoteById(int id) async {
    final url = Uri.parse('${AppConfig.baseUrl}/note/delete/$id');
    final response = await http.get(url);

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제되었습니다.')));
      _fetchMonthlyNotes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패')));
    }
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, BoxConstraints constraints,
      {bool isToday = false}) {
    final events = _getEventsForDay(day);
    final List<Map<String, dynamic>> mappedEvents = events.whereType<Map<String, dynamic>>().toList();

    int safeParseAmount(Map<String, dynamic> e) {
      final value = e['amount'];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    final income = mappedEvents.where((e) => e['isIncome'] == true).fold<int>(0, (sum, e) => sum + safeParseAmount(e));
    final expense = mappedEvents.where((e) => e['isIncome'] == false).fold<int>(0, (sum, e) => sum + safeParseAmount(e));
    final net = income - expense;
    final formatter = NumberFormat('#,###');

    return Container(
      height: constraints.maxHeight / 6.5,
      width: constraints.maxWidth / 7,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                color: isToday ? AppColors.primary.withOpacity(0.8) : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (income > 0)
            Text('+${formatter.format(income)}', style: TextStyle(fontSize: 7, color: AppColors.incomeBlue)),
          if (expense > 0)
            Text('-${formatter.format(expense)}', style: TextStyle(fontSize: 7, color: AppColors.expenseRed)),
          Text('${net >= 0 ? '+' : '-'}${formatter.format(net.abs())}',
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuickAddScreen(
        onSaved: _fetchMonthlyNotes,
      )),
    );

    if (result == true) {
      await _fetchMonthlyNotes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showMonthSelector,
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20),
              SizedBox(width: 6),
              Text('${_selectedYear}년 ${_selectedMonth}월'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isCalendarView ? Icons.view_list : Icons.calendar_month),
            onPressed: _toggleView,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'note_month_fab',
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/note/add',
            arguments: null,
          );

          if (result is DateTime) {
            setState(() {
              _focusedDay = result;
              _selectedYear = result.year;
              _selectedMonth = result.month;
            });
            await _fetchMonthlyNotes();
          }
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: NoteDecorations.summaryBox,
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('총수입', style: NoteTextStyles.total),
                    Text('${formatter.format(_monthlyIncome)}원', style: NoteTextStyles.income),
                  ]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('총지출', style: NoteTextStyles.total),
                    Text('${formatter.format(_monthlyExpense)}원', style: NoteTextStyles.expense),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isCalendarView
                  ? LayoutBuilder(
                builder: (context, constraints) {
                  return TableCalendar(
                    key: ValueKey(_groupedNotes.length),
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    eventLoader: _getEventsForDay,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: '',
                    },
                    headerVisible: false,
                    rowHeight: constraints.maxHeight / 6.5,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(),
                      selectedDecoration: BoxDecoration(),
                      todayTextStyle: TextStyle(),
                      selectedTextStyle: TextStyle(),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) =>
                          _buildCalendarCell(context, day, constraints, isToday: false),
                      todayBuilder: (context, day, focusedDay) =>
                          _buildCalendarCell(context, day, constraints, isToday: true),
                      selectedBuilder: (context, day, focusedDay) =>
                          _buildCalendarCell(context, day, constraints, isToday: false),
                      markerBuilder: (context, date, events) => const SizedBox(),
                    ),
                  );
                },
              )
                  : NoteListWidget(
                key: ValueKey(_groupedNotes.length),
                groupedNotes: _groupedNotes,
                onDelete: _deleteNoteById,
                onDataChanged: _fetchMonthlyNotes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
