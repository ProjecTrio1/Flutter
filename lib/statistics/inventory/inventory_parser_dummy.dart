//더미 데이터 나중에 삭제할 것

import 'dart:io';

class InventoryParserDummy {
  static Future<List<String>> analyze(File imageFile) async {
    final fileName = imageFile.path.toLowerCase();

    if (fileName.contains('apple')) {
      return ['사과'];
    } else if (fileName.contains('milk')) {
      return ['우유'];
    } else if (fileName.contains('combo')) {
      return ['사과', '우유', '당근'];
    }

    return ['당근', '양파'];
  }
}
