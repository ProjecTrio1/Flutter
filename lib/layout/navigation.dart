import 'package:flutter/material.dart';
import '../home/main_home.dart';
import '../statistics/statistics_home.dart ';
import '../note/note_home.dart';
import '../group/group_home.dart';
import '../setting/setting_home.dart';
import '../note/note_add.dart'; // QuickAddScreen

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 2; // 기본 홈 화면

  final List<Widget> _pages = [
    NoteHomeScreen(),    // 0: 가계부
    StatisticsHome(),  // 1: 자산
    MenuHomeScreen(),    // 2: 홈
    GroupHomeScreen(),   // 3: 그룹
    SettingHomeScreen(), // 4: 마이페이지
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 공통 AppBar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LOGO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.black),
                    SizedBox(width: 12),
                    Icon(Icons.menu, color: Colors.black),
                  ],
                )
              ],
            ),
          ),
        ),
      ),

      // 현재 선택된 페이지
      body: _pages[_selectedIndex],

      // 홈 또는 가계부 일 때만 플로팅 버튼 표시
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2)
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuickAddScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      )
          : null,

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '가계부'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '마이페이지'),
        ],
      ),
    );
  }
}
