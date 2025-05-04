import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_date.dart';
import 'note_list.dart';

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

    print('>> 현재 로그인된 userID: $userID');

    if (userID == null) {
      print('>> 오류: userID가 null입니다.');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/note/list?userID=$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> notes = jsonDecode(utf8.decode(response.bodyBytes));
      Map<DateTime, List<Map<String, dynamic>>> grouped = {};
      int income = 0;
      int expense = 0;

      print('>> 받아온 note 개수: ${notes.length}');

      for (var note in notes) {
        final raw = note['createdAt']?.toString();
        if (raw == null) continue;

        final date = DateTime.parse(raw).toLocal();  // toLocal이 문제일 수도 있음
        print('>> Note 날짜: $date');

        if (date.year == _selectedYear && date.month == _selectedMonth) {
          final key = normalizeDate(date);
          grouped.putIfAbsent(key, () => []).add(note);

          final amount = int.tryParse(note['amount'].toString()) ?? 0;
          final isIncome = note['isIncome'] == true;

          print(' - ${isIncome ? "수입" : "지출"} | ${amount}원 | 날짜: $key');

          if (isIncome) income += amount;
          else expense += amount;
        }
      }

      print('>> 최종 계산된 수입: $income, 지출: $expense');

      setState(() {
        _groupedNotes = grouped;
        _monthlyIncome = income;
        _monthlyExpense = expense;
      });
    } else {
      print('>> 오류: 응답 실패 status=${response.statusCode}');
    }
  }


  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = normalizeDate(day);
    final raw = _groupedNotes[key] ?? [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDateScreen(selectedDate: selected)),
    );
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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 년월 선택 및 전환 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showMonthSelector,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined),
                        SizedBox(width: 5),
                        Text('${_selectedYear}년 ${_selectedMonth}월',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isCalendarView ? Icons.list : Icons.calendar_month),
                    onPressed: _toggleView,
                  ),
                ],
              ),
              SizedBox(height: 10),
              // 수입 지출 요약
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('총수입', style: TextStyle(fontSize: 16)),
                      Text('${formatter.format(_monthlyIncome)}원'),
                    ]),
                    SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('총지출', style: TextStyle(fontSize: 16)),
                      Text('${formatter.format(_monthlyExpense)}원'),
                    ]),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: isCalendarView
                    ? TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return SizedBox();
                      final safeEvents = events.whereType<Map<String, dynamic>>().toList();

                      final incomeNotes = safeEvents.where((e) => (e['isIncome'] ?? false) == true && e['amount'] != null);
                      final expenseNotes = safeEvents.where((e) => (e['isIncome'] ?? true) == false && e['amount'] != null);

                      int income = incomeNotes.fold(0, (sum, e) => sum + (e['amount'] as int));
                      int expense = expenseNotes.fold(0, (sum, e) => sum + (e['amount'] as int));
                      int net = income - expense;

                      if (income == 0 && expense == 0) return SizedBox();

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (income > 0)
                            Text('+${formatter.format(income)}',
                                style: TextStyle(color: Colors.blue, fontSize: 10)),
                          if (expense > 0)
                            Text('-${formatter.format(expense)}',
                                style: TextStyle(color: Colors.red, fontSize: 10)),
                          Text(
                            '${net >= 0 ? "+" : "-"}${formatter.format(net.abs())}',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                )
                    : NoteListScreen(year: _selectedYear, month: _selectedMonth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
