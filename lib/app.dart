import 'package:flutter/material.dart';

import 'screens/login_page.dart';

class UteNavigationApp extends StatelessWidget {
  const UteNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTE AR Navigation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F8C)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
