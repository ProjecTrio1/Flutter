import 'package:flutter/material.dart';
import '../config.dart';
import '../home/main_home.dart';
import 'package:http/http.dart' as http;
import 'signup_home.dart';// main_home.dart 경로 임포트
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../layout/navigation.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  State<LoginHome> createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  //final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final url = Uri.parse('${AppConfig.baseUrl}/user/login');
    print('📡 요청 URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📨 응답 상태코드: ${response.statusCode}');
      print('📨 응답 바디: ${response.body}');

      final rBody = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(rBody);
      String message = decoded is Map && decoded.containsKey('message')
          ? decoded['message']
          : rBody;

      if (response.statusCode == 200 && decoded['user'] != null) {
        final user = decoded['user'];
        final userID = user['id'];
        print("✅ 로그인 성공 - userID: $userID");

        final share = await SharedPreferences.getInstance();
        await share.setInt('userID', userID);
        await share.setString('email', email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
        return;
      } else {
        print("❌ 로그인 실패 상태코드: ${response.statusCode}");
        _showDialog(message);
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      _showDialog('서버 응답 오류 또는 연결 실패');
    }
  }

/* 서버 없이 테스트

    final testUserID = 1; // 테스트용 ID
    final share = await SharedPreferences.getInstance();
    await share.setInt('userID', testUserID);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Navigation()),
    );
*/

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TextField(
            //   controller: _nameController,
            //   decoration: const InputDecoration(labelText: '이름'),
            // ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '비밀번호',
                suffixIcon: IconButton(
                  icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _submitForm, child: Text('로그인')),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupHome()));
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
