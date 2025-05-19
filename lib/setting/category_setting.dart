import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/main_style.dart';
import '../style/note_style.dart';

class CategorySettingScreen extends StatefulWidget {
  const CategorySettingScreen({Key? key}) : super(key: key);

  @override
  State<CategorySettingScreen> createState() => _CategorySettingScreenState();
}

class _CategorySettingScreenState extends State<CategorySettingScreen> {
  final List<String> _categories = [];
  final Map<String, int> _monthlyLimits = {};
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('expenseCategories');
    if (saved != null) {
      setState(() {
        _categories.addAll(saved);
        for (var cat in saved) {
          _monthlyLimits[cat] = prefs.getInt('limit_$cat') ?? 0;
        }
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('expenseCategories', _categories);
    for (var cat in _categories) {
      await prefs.setInt('limit_$cat', _monthlyLimits[cat] ?? 0);
    }
  }

  void _addCategory() {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _monthlyLimits[newCategory] = 0;
        _categoryController.clear();
      });
      _saveCategories();
    }
  }

  void _deleteCategory(String cat) {
    setState(() {
      _categories.remove(cat);
      _monthlyLimits.remove(cat);
    });
    _saveCategories();
  }

  void _showLimitDialog(String category) {
    int tempLimit = _monthlyLimits[category] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$category - 월간 지출 한도'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (tempLimit >= 1000) tempLimit -= 1000;
                  });
                },
              ),
              Text('$tempLimit원', style: AppTextStyles.bold),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() => tempLimit += 1000);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _monthlyLimits[category] = tempLimit;
                });
                _saveCategories();
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text('카테고리 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    child: ListTile(
                      title: Text(category, style: NoteTextStyles.subHeader),
                      subtitle: Text('월 한도: ${_monthlyLimits[category]}원', style: NoteTextStyles.subtitle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => _showLimitDialog(category),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}

