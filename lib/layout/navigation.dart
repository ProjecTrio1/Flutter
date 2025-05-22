import 'package:flutter/material.dart';
import '../home/main_home.dart';
import '../statistics/statistics_home.dart';
import '../note/note_home.dart';
import '../group/group_home.dart';
import '../setting/setting_home.dart';
import '../note/note_add.dart'; // QuickAddScreen
import '../group/post_add.dart';
import '../style/main_style.dart';

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 2; // 기본 홈 화면

  final List<Widget> _pages = [
    NoteHomeScreen(),           // 0: 가계부
    StatisticsHome(),           // 1: 자산
    MenuHomeScreen(),           // 2: 홈
    GroupHomeScreen(           // 3: 그룹
      username: 'test1',       // 더미 사용자 이름
      userID: 9,               // 더미 사용자 ID
    ),
    SettingHomeScreen(),        // 4: 마이페이지
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
                Text('LOGO', style: AppTextStyles.title),
                Icon(Icons.notifications, color: AppColors.textPrimary),
              ],
            ),
          ),
        ),
      ),


      // 현재 선택된 페이지
      body: _pages[_selectedIndex],

      // 플로팅 버튼 표시
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3)
          ? FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0 || _selectedIndex == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuickAddScreen()),
            );
          } else if (_selectedIndex == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupPostAddScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: Icon(
          _selectedIndex == 3 ? Icons.create : Icons.add,
          color: Colors.white,
          size: 28,
        ),
        elevation: 4,
      )
          : null,


      // 하단 네비게이션 바
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: AppTextStyles.navLabel,
          unselectedLabelStyle: AppTextStyles.navLabel.copyWith(
            fontWeight: FontWeight.normal,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '가계부'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '자산'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}
