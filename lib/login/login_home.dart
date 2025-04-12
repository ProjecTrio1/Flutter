import 'package:flutter/material.dart';
import '../home/main_home.dart';
import 'package:http/http.dart' as http;
import 'signup_home.dart';// main_home.dart 경로 임포트
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  State<LoginHome> createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() async{
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final url = Uri.parse('http://10.0.2.2:8080/user/login'); // Android 에뮬레이터 기준 IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username' :name,
        'email' : email,
        'password' : password,
      }),
    );
    String message = '로그인 실패';
    try {
      final rBody = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(rBody);
      message = decoded is Map && decoded.containsKey('message')
          ? decoded['message']
          : rBody;
      if(response.statusCode == 200 && decoded['user'] != null){
        final user = decoded['user'];
        final userID = user['id'];
        print("userID: $userID");

        final share = await SharedPreferences.getInstance();
        await share.setInt('userID', userID);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MenuHomeScreen()),);
        return;
      }
    } catch (e) {
      message = '서버 응답 파싱 오류';
    }
    _showDialog(message);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuHomeScreen()),
      );
    } else {
      _showDialog(message);
    }

  }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인/회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("버튼 눌림");
                    _submitForm();
                  },
                  child: const Text('로그인'),
                ),
                TextButton(
                  onPressed: () {
                    // 회원가입 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupHome()),
                    );
                  },
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
