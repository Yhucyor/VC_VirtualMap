import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/auth/screens/login_page.dart';

class UteNavigationApp extends StatelessWidget {
  const UteNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTE AR Navigation',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
