import 'package:flutter/material.dart';

class GroupHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('그룹')),
      body: Center(child: Text('그룹 홈', style: TextStyle(fontSize: 18))),
    );
  }
}
