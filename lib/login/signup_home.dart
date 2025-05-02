import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupHome extends StatefulWidget {
  const SignupHome({super.key});

  @override
  State<SignupHome> createState() => _SignupHomeState();
}
enum Gender {male, female}

class _SignupHomeState extends State<SignupHome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();
  Gender _selectedGender = Gender.male;

  void _signup() async{
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordCheck = _passwordCheckController.text;
    final genderStr = _selectedGender == Gender.male ? 'M' : 'F';

    if (password != passwordCheck) {
      _showDialog('비밀번호가 일치하지 않습니다.');
      return;
    }
    final url = Uri.parse('http://10.0.2.2:8080/user/signup'); // Android 에뮬레이터 기준 IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username' :name,
        'email' : email,
        'password1' : password,
        'password2' : passwordCheck,
        'gender' : genderStr,
      }),
    );
    if (response.statusCode == 200) {
      _showDialog('성공',onClose:(){
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _passwordCheckController.clear();
        Navigator.pop(context);
      });
    }else if(response.statusCode == 409) {
      _showDialog('이미 존재하는 사용자입니다.');
    }else if(response.statusCode == 400){
      _showDialog('2개의 비밀번호가 일치하지 않습니다.');
    } else {
      _showDialog('회원가입 실패 : ${response.body}');
    }
  }

  void _showDialog(String message, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              if (onClose != null) {
                onClose();
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  bool _isPasswordVisible = false;
  bool _isPasswordCheckVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            ListTile(
              title: const Text('남성'),
              leading: Radio<Gender>(
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (Gender? value){
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('여성'),
              leading: Radio<Gender>(
                value: Gender.female,
                groupValue: _selectedGender,
                onChanged: (Gender? value){
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordCheckController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordCheckVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      _isPasswordCheckVisible = !_isPasswordCheckVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordCheckVisible,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
