import 'package:flutter/material.dart';
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
  final TextEditingController _categoryController = TextEditingController();

  bool isExpenseTab = false; // 수입이 왼쪽이 되도록 false로 시작
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

    for (var cat in expense) {
      limits[cat] = await CategoryStorage.getLimit(cat);
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
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategories() async {
    await CategoryStorage.saveExpenseCategories(_expenseCategories, _monthlyLimits);
    await CategoryStorage.saveIncomeCategories(_incomeCategories);
  }

  void _addCategory() {
    final newCategory = _categoryController.text.trim();
    final currentList = isExpenseTab ? _expenseCategories : _incomeCategories;
    if (newCategory.isNotEmpty && !currentList.contains(newCategory)) {
      setState(() {
        currentList.add(newCategory);
        if (isExpenseTab) _monthlyLimits[newCategory] = 0;
        _categoryController.clear();
      });
      _saveCategories();
    }
  }

  void _deleteCategory(String cat) {
    final currentList = isExpenseTab ? _expenseCategories : _incomeCategories;
    final defaultList = isExpenseTab
        ? CategoryStorage.defaultExpense
        : CategoryStorage.defaultIncome;

    // 기본 카테고리는 삭제 불가
    if (defaultList.contains(cat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 카테고리는 삭제할 수 없습니다.')),
      );
      return;
    }

    if (currentList.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 1개의 카테고리는 유지해야 합니다.')),
      );
      return;
    }

    setState(() {
      currentList.remove(cat);
      if (isExpenseTab) _monthlyLimits.remove(cat);
    });
    _saveCategories();
  }

  void _showLimitDialog(String category) {
    final TextEditingController limitController =
    TextEditingController(text: (_monthlyLimits[category] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$category - 월간 지출 한도'),
        content: TextField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '숫자 입력 (원)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final int? parsed = int.tryParse(limitController.text.trim());
              if (parsed != null) {
                setState(() {
                  _monthlyLimits[category] = parsed;
                });
                CategoryStorage.setLimit(category, parsed);
              }
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
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
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: '카테고리 이름 입력',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: Text('추가'),
                  style: NoteDecorations.filledButton,
                ),
              ],
            ),
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
                          ? Text('월 한도: ${_monthlyLimits[category]}원',
                          style: NoteTextStyles.subtitle)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isExpenseTab)
                            IconButton(
                              icon: Icon(Icons.settings),
                              onPressed: () => _showLimitDialog(category),
                            ),
                          if (!(isExpenseTab
                              ? CategoryStorage.defaultExpense.contains(category)
                              : CategoryStorage.defaultIncome.contains(category)))
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category),
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
