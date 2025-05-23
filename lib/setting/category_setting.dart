import 'package:flutter/material.dart';
import '../config.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';
import 'category_helper.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({Key? key}) : super(key: key);

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {
  final List<String> _expenseCategories = [];
  final List<String> _incomeCategories = [];
  final Map<String, int> _monthlyLimits = {};
  final Map<String, bool> _limitNotifications = {};
  final TextEditingController _categoryController = TextEditingController();

  bool isExpenseTab = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final expense = await CategoryStorage.loadExpenseCategories();
    final income = await CategoryStorage.loadIncomeCategories();
    final limits = <String, int>{};
    final notifies = <String, bool>{};

    for (var cat in expense) {
      limits[cat] = await CategoryStorage.getLimit(cat);
      notifies[cat] = await CategoryStorage.getLimitNotify(cat);
    }

    if (mounted) {
      setState(() {
        _expenseCategories
          ..clear()
          ..addAll(expense);
        _incomeCategories
          ..clear()
          ..addAll(income);
        _monthlyLimits
          ..clear()
          ..addAll(limits);
        _limitNotifications
          ..clear()
          ..addAll(notifies);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategories() async {
    await CategoryStorage.saveExpenseCategories(_expenseCategories, _monthlyLimits);
    await CategoryStorage.saveIncomeCategories(_incomeCategories);
  }

  // void _addCategory() {
  //   final newCategory = _categoryController.text.trim();
  //   final currentList = isExpenseTab ? _expenseCategories : _incomeCategories;
  //   if (newCategory.isNotEmpty && !currentList.contains(newCategory)) {
  //     setState(() {
  //       currentList.add(newCategory);
  //       if (isExpenseTab) {
  //         _monthlyLimits[newCategory] = 0;
  //         _limitNotifications[newCategory] = true;
  //       }
  //       _categoryController.clear();
  //     });
  //     _saveCategories();
  //   }
  // }

  // void _deleteCategory(String cat) {
  //   final currentList = isExpenseTab ? _expenseCategories : _incomeCategories;
  //   final defaultList = isExpenseTab
  //       ? CategoryStorage.defaultExpense
  //       : CategoryStorage.defaultIncome;

  //   if (defaultList.contains(cat)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('기본 카테고리는 삭제할 수 없습니다.')),
  //     );
  //     return;
  //   }

  //   if (currentList.length == 1) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('최소 1개의 카테고리는 유지해야 합니다.')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     currentList.remove(cat);
  //     if (isExpenseTab) {
  //       _monthlyLimits.remove(cat);
  //       _limitNotifications.remove(cat);
  //     }
  //   });
  //   _saveCategories();
  // }

  void _showLimitDialog(String category) async {
    final TextEditingController limitController =
    TextEditingController(text: (_monthlyLimits[category] ?? 0).toString());
    bool notifyValue = _limitNotifications[category] ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('$category - 월간 지출 한도'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '숫자 입력 (원)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('한도 초과 시 알림'),
                value: notifyValue,
                onChanged: (val) => setStateDialog(() => notifyValue = val),
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.4),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final int? parsed = int.tryParse(limitController.text.trim());
                if (parsed != null) {
                  setState(() {
                    _monthlyLimits[category] = parsed;
                    _limitNotifications[category] = notifyValue;
                  });
                  await CategoryStorage.setLimit(category, parsed);
                  await CategoryStorage.setLimitNotify(category, notifyValue);
                }
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = isExpenseTab ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text('카테고리 설정')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ToggleButtons(
                isSelected: [!isExpenseTab, isExpenseTab],
                onPressed: (index) {
                  setState(() => isExpenseTab = index == 1);
                },
                borderRadius: BorderRadius.circular(8),
                fillColor: isExpenseTab
                    ? AppColors.expenseRed
                    : AppColors.incomeBlue,
                selectedColor: Colors.white,
                color: AppColors.textSecondary,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('수입'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('지출'),
                  ),
                ],
              ),
            ),

            // ---- 카테고리 추가 UI (비활성화) ----
            // SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: _categoryController,
            //         decoration: InputDecoration(
            //           hintText: '카테고리 이름 입력',
            //           border: OutlineInputBorder(),
            //           fillColor: Colors.white,
            //           filled: true,
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 8),
            //     ElevatedButton(
            //       onPressed: _addCategory,
            //       child: Text('추가'),
            //       style: NoteDecorations.filledButton,
            //     ),
            //   ],
            // ),

            SizedBox(height: 24),
            Expanded(
              child: currentList.isEmpty
                  ? Center(child: Text('카테고리가 없습니다.'))
                  : ListView.builder(
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final category = currentList[index];
                  return Card(
                    child: ListTile(
                      title: Text(category, style: NoteTextStyles.subHeader),
                      subtitle: isExpenseTab
                          ? Text(
                        '월 한도: ${_monthlyLimits[category]}원 / 알림: ${(_limitNotifications[category] ?? true) ? 'ON' : 'OFF'}',
                        style: NoteTextStyles.subtitle,
                      )
                          : null,
                      trailing: isExpenseTab
                          ? IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => _showLimitDialog(category),
                      )
                          : null,
                      // 삭제 버튼 (비활성화)
                      // trailing: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     if (isExpenseTab)
                      //       IconButton(
                      //         icon: Icon(Icons.settings),
                      //         onPressed: () => _showLimitDialog(category),
                      //       ),
                      //     if (!(isExpenseTab
                      //         ? CategoryStorage.defaultExpense.contains(category)
                      //         : CategoryStorage.defaultIncome.contains(category)))
                      //       IconButton(
                      //         icon: Icon(Icons.delete, color: Colors.red),
                      //         onPressed: () => _deleteCategory(category),
                      //       ),
                      //   ],
                      // ),
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
