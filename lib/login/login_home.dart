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

  void _submitForm() async{
    // final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    /* 서버 테스트*/
    final url = Uri.parse('${AppConfig.baseUrl}/user/login'); // Android 에뮬레이터 기준 IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        // 'username' :name,
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
      if (response.statusCode == 200 && decoded['user'] != null) {
        final user = decoded['user'];
        final userID = user['id'];
        print("userID: $userID");

        final share = await SharedPreferences.getInstance();
        await share.setInt('userID', userID);
        await share.setString('email', email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
        return;
      }
    } catch (e) {
      message = '서버 응답 파싱 오류';
    }
    _showDialog(message);


     /* 서버 없이 테스트

    final testUserID = 1; // 테스트용 ID
    final share = await SharedPreferences.getInstance();
    await share.setInt('userID', testUserID);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Navigation()),
    );
*/
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
