import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupHome extends StatefulWidget {
  const SignupHome({super.key});

  @override
  State<SignupHome> createState() => _SignupHomeState();
}

enum Gender { male, female }

class _SignupHomeState extends State<SignupHome> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();

  Gender _selectedGender = Gender.male;
  int _selectAge = 2;

  bool _isPasswordVisible = false;
  bool _isPasswordCheckVisible = false;

  final Map<int, String> ageGroups = {
    1: '10대 미만',
    2: '10-19세',
    3: '20-29세',
    4: '30-39세',
    5: '40-49세',
    6: '50-59세',
    7: '60-69세',
    8: '70-79세',
    9: '80-89세',
    10: '90-99세',
    11: '100세 이상',
  };

  final Map<String, String> _errorMessages = {};

  void _signup() async {
    setState(() {
      _errorMessages.clear();
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordCheck = _passwordCheckController.text;
    final genderStr = _selectedGender == Gender.male ? 'M' : 'F';

    // 클라이언트 유효성 검사
    if (name.length < 3 || name.length > 25) {
      setState(() {
        _errorMessages['username'] = '이름은 3~25자 사이여야 합니다.';
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _errorMessages['email'] = '이메일 형식이 아닙니다.';
      });
      return;
    }

    if (password.length < 8 || password.length > 20) {
      setState(() {
        _errorMessages['password'] = '비밀번호는 8~20자 사이여야 합니다.';
      });
      return;
    }

    if (password != passwordCheck) {
      setState(() {
        _errorMessages['passwordCheck'] = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    // 서버 전송
    final url = Uri.parse('${AppConfig.baseUrl}/user/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password1': password,
        'password2': passwordCheck,
        'gender': genderStr,
        'age': _selectAge,
      }),
    );

    if (response.statusCode == 200) {
      _showDialog('회원가입 성공', onClose: () {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _passwordCheckController.clear();
        Navigator.pop(context);
      });
    } else if (response.statusCode == 409) {
      _showDialog('이미 존재하는 사용자입니다.');
    } else if (response.statusCode == 400) {
      try {
        final error = jsonDecode(response.body);
        setState(() {
          if (error['message'].contains('이메일')) {
            _errorMessages['email'] = error['message'];
          } else if (error['message'].contains('비밀번호')) {
            _errorMessages['password'] = error['message'];
          } else if (error['message'].contains('사용자')) {
            _errorMessages['username'] = error['message'];
          } else {
            _errorMessages['general'] = error['message'];
          }
        });
      } catch (_) {
        _showDialog('회원가입 실패: ${response.body}');
      }
    } else {
      _showDialog('회원가입 실패: ${response.body}');
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
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText(String fieldKey) {
    if (_errorMessages[fieldKey]?.isNotEmpty == true) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          _errorMessages[fieldKey]!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildErrorText('username'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 12),

            _buildErrorText('email'),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            const Text('성별'),
            ListTile(
              title: const Text('남성'),
              leading: Radio<Gender>(
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
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
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectAge,
              decoration: const InputDecoration(
                labelText: '연령대',
                border: OutlineInputBorder(),
              ),
              items: ageGroups.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectAge = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildErrorText('password'),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                suffixIcon: IconButton(
                  icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 12),

            _buildErrorText('passwordCheck'),
            TextField(
              controller: _passwordCheckController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                suffixIcon: IconButton(
                  icon: Icon(
                      _isPasswordCheckVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordCheckVisible = !_isPasswordCheckVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordCheckVisible,
            ),

            if (_errorMessages['general']?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(_errorMessages['general']!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signup,
                child: const Text('회원가입 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
