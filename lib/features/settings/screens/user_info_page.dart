// lib/features/settings/screens/user_info_page.dart
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin người dùng')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.2),
                AppTheme.secondary.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              SizedBox(height: 16),
              Text(
                'Tên người dùng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Mã sinh viên: SV001'),
              Text('Email: example@ute.edu.vn'),
            ],
          ),
        ),
      ),
    );
  }
}
