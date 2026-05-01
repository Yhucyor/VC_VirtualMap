import 'package:flutter/material.dart';

import '../features/auth/screens/login_page.dart';
import 'ute_map_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.themeNotifier});

  final ValueNotifier<bool> themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                const UteMapLogo(size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'camapus',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Campus map & AR navigation'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Bản đồ trường đại học'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed('/campusMap'),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Tìm địa điểm/phòng học'),
            onTap: () => Navigator.of(context).pushNamed('/placeSearch'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Hướng dẫn sử dụng'),
            onTap: () => Navigator.of(context).pushNamed('/guide'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông tin người dùng'),
            onTap: () => Navigator.of(context).pushNamed('/userInfo'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
          const Divider(),
          ValueListenableBuilder<bool>(
            valueListenable: themeNotifier,
            builder: (context, isDark, _) {
              return SwitchListTile(
                title: const Text('Chế độ tối'),
                value: isDark,
                onChanged: (val) => themeNotifier.value = val,
                secondary: const Icon(Icons.dark_mode),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
