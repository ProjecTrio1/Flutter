import 'package:flutter/foundation.dart';

class AppConfig {
  static final String baseUrl = kReleaseMode
      ? 'http://192.168.0.2:8080' // 실기기 테스트용 (와이파이 연결)
      : 'http://10.0.2.2:8080';// 에뮬레이터용

  static const String flaskUrl = kReleaseMode // Flask용
      ? 'http://192.168.0.2:5000'
      : 'http://10.0.2.2:5000';
}