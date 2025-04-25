import 'package:flutter/material.dart';

class NoteHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('가계부')),
      body: Center(child: Text('가계부 홈', style: TextStyle(fontSize: 18))),
    );
  }
}