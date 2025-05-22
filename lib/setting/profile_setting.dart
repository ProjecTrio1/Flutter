import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

enum Gender { male, female }

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();
  Gender _selectedGender = Gender.male;
  int _selectAge = 2;
  String? _email;

  final Map<int, String> ageGroups = {
    1: '10대 미만', 2: '10-19세', 3: '20-29세', 4: '30-39세',
    5: '40-49세', 6: '50-59세', 7: '60-69세', 8: '70-79세',
    9: '80-89세', 10: '90-99세', 11: '100세 이상'
  };

  bool _isPasswordVisible = false;
  bool _isPasswordCheckVisible = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.parse('http://10.0.2.2:8080/user/profile/$userID');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _nameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _selectedGender = data['gender'] == 'F' ? Gender.female : Gender.male;
        _selectAge = data['age'] ?? 2;
      });
    }
  }

  void _submitUpdate() async {
    if (_passwordController.text != _passwordCheckController.text) {
      _showDialog('비밀번호가 일치하지 않습니다.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final genderStr = _selectedGender == Gender.male ? 'M' : 'F';

    final url = Uri.parse('http://10.0.2.2:8080/user/update/$userID');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _nameController.text,
        'password': _passwordController.text,
        'gender': genderStr,
        'age': _selectAge,
      }),
    );

    if (response.statusCode == 200) {
      _showDialog('정보가 성공적으로 수정되었습니다.');
    } else {
      _showDialog('수정 실패: ${response.body}');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원 정보 수정')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              readOnly: true,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(labelText: '이메일'),
            ),
            SizedBox(height: 12),
            ListTile(
              title: Text('남성'),
              leading: Radio<Gender>(
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
            ),
            ListTile(
              title: Text('여성'),
              leading: Radio<Gender>(
                value: Gender.female,
                groupValue: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
            ),
            DropdownButtonFormField<int>(
              value: _selectAge,
              decoration: InputDecoration(labelText: '연령대'),
              items: ageGroups.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _selectAge = value!),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '새 비밀번호',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordCheckController,
              obscureText: !_isPasswordCheckVisible,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordCheckVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordCheckVisible = !_isPasswordCheckVisible),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitUpdate,
              child: Text('정보 수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
