import 'package:shared_preferences/shared_preferences.dart';

class CategoryStorage {
  static const List<String> defaultExpense = [
    '식비', '카페/디저트', '교통/차량', '쇼핑/생활/뷰티',
    '건강/의료', '교육/학원', '문화/여가', '기타'
  ];

  static const List<String> defaultIncome = [
    '월급', '용돈', '기타'
  ];

  // 지출 카테고리 불러오기
  static Future<List<String>> loadExpenseCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('expenseCategories');
    return (list == null || list.isEmpty) ? defaultExpense : list;
  }

  // 수입 카테고리 불러오기
  static Future<List<String>> loadIncomeCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('incomeCategories');
    return (list == null || list.isEmpty) ? defaultIncome : list;
  }

  // 지출 카테고리 저장 + 월 한도 저장
  static Future<void> saveExpenseCategories(List<String> list, Map<String, int> limits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('expenseCategories', list);
    for (var cat in list) {
      await prefs.setInt('limit_$cat', limits[cat] ?? 0);
    }
  }

  // 수입 카테고리 저장
  static Future<void> saveIncomeCategories(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('incomeCategories', list);
  }

  // 특정 카테고리의 월 한도 불러오기
  static Future<int> getLimit(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('limit_$category') ?? 0;
  }

  // 특정 카테고리의 월 한도 저장하기
  static Future<void> setLimit(String category, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('limit_$category', value);
  }

  static Future<bool> getLimitNotify(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('limit_notify_$category') ?? true;
  }

  static Future<void> setLimitNotify(String category, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('limit_notify_$category', value);
  }

}
