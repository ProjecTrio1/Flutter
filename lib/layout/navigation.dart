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
import 'notification_panel.dart';
import 'overspend_feedback_dialog.dart';
import '../setting/reminder_manager.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReminderFeedbackPopup();
    });
  }

  void _checkReminderFeedbackPopup() async {
    final reminders = await ReminderManager.loadReminderItems();
    final now = DateTime.now();

    for (final r in reminders) {
      final createdAt = DateTime.tryParse(r['createdAt'] ?? '');
      final feedback = r['feedback'] ?? '';

      // 테스트 위해 조건 강제 수정
      // 기존 조건: if (createdAt != null && now.difference(createdAt).inDays >= 30 && feedback.isEmpty)
      if (createdAt != null && feedback.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => OverspendFeedbackDialog(reminder: r),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.only(top: 0, left: 25, right: 10, bottom: 0),
          color: AppColors.background,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo/logo_icon.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: AppColors.textPrimary),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const NotificationPanel(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),

      body: _pages[_selectedIndex],

      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3)
          ? FloatingActionButton(
        heroTag: _selectedIndex == 0
            ? 'fab_note'
            : _selectedIndex == 2
            ? 'fab_home'
            : 'fab_group',
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
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 28),
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