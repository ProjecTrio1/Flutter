import 'package:flutter/material.dart';
import '../config.dart';
import '../style/main_style.dart';
import 'password_confirm.dart';
import 'profile_setting.dart';
import 'category_setting.dart';
import 'reminder_setting.dart';
import 'notice.dart';
import 'help.dart';
import 'contact.dart';
import '../login/login_home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingHomeScreen extends StatelessWidget {
  const SettingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _buildSettingTile(
          //   context,
          //   icon: Icons.person,
          //   title: '회원 정보 수정',
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (_) => EditProfileScreen()),
          //   ),
          // ),
          _buildSettingTile(
            context,
            icon: Icons.category,
            title: '카테고리 수정 / 한도 설정',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategorySettingScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_active,
            title: '한 달 뒤 다시 알림 설정',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReminderSettingScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.announcement,
            title: '공지사항',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NoticeScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: '도움말',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HelpScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.mail_outline,
            title: '문의하기',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactScreen()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: '로그아웃',
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // 모든 저장된 로그인 정보 삭제

              // 로그인 화면으로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginHome()),
                    (route) => false,
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          top: BorderSide(color: AppColors.borderGray.withOpacity(0.4)),
          bottom: BorderSide(color: AppColors.borderGray.withOpacity(0.4)),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: AppTextStyles.body),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
