import 'package:http/http.dart' as http;

class HttpClientWithCookies {
  static final _client = http.Client();
  static Map<String, String> cookies = {};

  static Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    headers = headers ?? {};
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }

    final response = await _client.post(url, headers: headers, body: body);
    _updateCookies(response);
    return response;
  }

  static Future<http.Response> get(Uri url,
      {Map<String, String>? headers}) async {
    headers = headers ?? {};
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }

    final response = await _client.get(url, headers: headers);
    _updateCookies(response);
    return response;
  }

  static void _updateCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final cookiesList = setCookie.split(',');
      for (var cookie in cookiesList) {
        final kv = cookie.split(';')[0].split('=');
        if (kv.length == 2) {
          cookies[kv[0].trim()] = kv[1].trim();
        }
      }
    }
  }
}
