import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/auth/screens/login_page.dart';
import 'features/campus_map/data/campus_catalog.dart';
import 'features/home/screens/app_home_page.dart';
import 'features/home/screens/campus_home_page.dart';
import 'features/home/screens/usage_guide_page.dart';
import 'features/place_search/screens/place_search_page.dart';
import 'features/settings/screens/settings_page.dart';
import 'features/settings/screens/user_info_page.dart';

void main() {
  runApp(const UteNavigationApp());
}

class UteNavigationApp extends StatefulWidget {
  const UteNavigationApp({super.key});

  @override
  State<UteNavigationApp> createState() => _UteNavigationAppState();
}

class _UteNavigationAppState extends State<UteNavigationApp> {
  final ValueNotifier<bool> _themeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<CampusProfile> _campusNotifier =
      ValueNotifier<CampusProfile>(campusCatalog.first);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'camapus',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const LoginPage(),
          routes: {
            '/home': (context) => AppHomePage(themeNotifier: _themeNotifier),
            '/campusMap': (context) => CampusHomePage(
              themeNotifier: _themeNotifier,
              selectedCampusNotifier: _campusNotifier,
            ),
            '/guide': (context) => const UsageGuidePage(),
            '/placeSearch': (context) =>
                PlaceSearchPage(selectedCampusNotifier: _campusNotifier),
            '/settings': (context) =>
                SettingsPage(themeNotifier: _themeNotifier),
            '/userInfo': (context) => const UserInfoPage(),
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    _campusNotifier.dispose();
    super.dispose();
  }
}
