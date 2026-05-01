import 'package:flutter/material.dart';

import '../../../shared/widgets/app_panel.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/ute_map_logo.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key, required this.themeNotifier});

  final ValueNotifier<bool> themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('camapus')),
      drawer: AppDrawer(themeNotifier: themeNotifier),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: UteMapLogo(size: 104)),
                  const SizedBox(height: 16),
                  Text(
                    'Giới thiệu ứng dụng',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'camapus hỗ trợ chọn trường đại học, xem bản đồ các khu/phòng/tòa, tìm phòng học hoặc địa điểm và mở dẫn đường AR đến điểm đã chọn.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/guide'),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Mở hướng dẫn sử dụng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
