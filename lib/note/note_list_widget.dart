import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../style/note_style.dart';
import 'note_add.dart';

class NoteListWidget extends StatelessWidget {
  final Map<DateTime, List<Map<String, dynamic>>> groupedNotes;
  final void Function(int id) onDelete;
  const NoteListWidget({
    Key? key,
    required this.groupedNotes,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final sortedDates = groupedNotes.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      children: [
        ...sortedDates.map((date) {
          final notes = groupedNotes[date]!;
          final weekdayStr = DateFormat('M월 d일 (E)', 'ko_KR').format(date);
          final net = notes.fold<int>(0, (sum, e) {
            final amount = (e['amount'] ?? 0) as num;
            return sum + ((e['isIncome'] ?? false) ? amount.toInt() : -amount.toInt());
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  //borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(weekdayStr, style: NoteTextStyles.subHeader),
                    Text(
                      '${net >= 0 ? '+' : '-'}${formatter.format(net.abs())}원',
                      style: TextStyle(color: net >= 0 ? NoteColors.income : NoteColors.expense),
                    ),
                  ],
                ),
              ),
              ...notes.map((note) {
                final time = DateFormat('HH:mm').format(DateTime.parse(note['createdAt']).toLocal());
                final amount = note['amount'] ?? 0;
                final isIncome = note['isIncome'] == true;
                final category = note['category'] ?? '';
                final content = note['content'] ?? '';
                final memo = note['memo'] ?? '';
                final id = note['id'];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NoteDecorations.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: NoteTextStyles.subtitle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(content, style: NoteTextStyles.subHeader)),
                          Row(
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}${formatter.format(amount)}원',
                                style: isIncome ? NoteTextStyles.income : NoteTextStyles.expense,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuickAddScreen(existingNote: note),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('삭제 확인'),
                                      content: Text('이 항목을 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (id != null) onDelete(id);
                                          },
                                          child: Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (memo.isNotEmpty) Text(memo, style: NoteTextStyles.subtitle),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(time, style: NoteTextStyles.time),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }
}
