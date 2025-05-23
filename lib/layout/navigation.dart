import 'package:flutter/material.dart';
import '../config.dart';
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
    NoteHomeScreen(), // 0: 가계부
    StatisticsHome(), // 1: 자산
    MenuHomeScreen(), // 2: 홈
    GroupHomeScreen( // 3: 그룹
      username: 'test1', // 더미 사용자 이름
      userID: 9, // 더미 사용자 ID
    ),
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

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 90,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('그알',
                        style: AppTextStyles.title.copyWith(fontSize: 20)),
                    Icon(Icons.notifications, color: AppColors.textPrimary),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),

      body: _pages[_selectedIndex],

      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2 ||
          _selectedIndex == 3)
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

      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '마이페이지'),
        ],
      ),
    );
  }
}