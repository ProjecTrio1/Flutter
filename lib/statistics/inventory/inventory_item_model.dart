class InventoryItem {
  final String? title;
  final String? price;
  final String? date;
  final String? imagePath;
  final List<String> parsedItems;
  final String category;

  InventoryItem({
    this.title,
    this.price,
    this.date,
    this.imagePath,
    this.parsedItems = const [],
    this.category = '식품',
  });

  // JSON → 객체 변환
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      title: json['title'],
      price: json['price'],
      date: json['date'],
      imagePath: json['imagePath'],
      parsedItems: _parseList(json['parsedItems']),
      category: json['category'] ?? '식품',
    );
  }

  // 객체 → JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'date': date,
      'imagePath': imagePath,
      'parsedItems': parsedItems,
      'category': category,
    };
  }

  // 문자열/리스트 둘 다 수용 가능
  static List<String> _parseList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data);
    if (data is String) return data.split(',');
    return [];
  }
}
