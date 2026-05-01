import 'package:flutter/material.dart';

import '../../../shared/widgets/app_panel.dart';

class UsageGuidePage extends StatelessWidget {
  const UsageGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn sử dụng')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _GuideStep(
              icon: Icons.school_outlined,
              title: '1. Chọn trường',
              text:
                  'Vào Bản đồ trường đại học, chọn trường bạn đang học hoặc trường bạn muốn đến.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              icon: Icons.map_outlined,
              title: '2. Xem bản đồ',
              text:
                  'App sẽ hiển thị tên trường, ảnh minh họa và bản đồ vị trí các khu, phòng, tòa tương ứng.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              icon: Icons.search,
              title: '3. Tìm phòng học/địa điểm',
              text:
                  'Vào Tìm địa điểm/phòng học. Danh sách kết quả sẽ tự lấy theo trường đã chọn trước đó.',
            ),
            SizedBox(height: 12),
            _GuideStep(
              icon: Icons.view_in_ar,
              title: '4. Dẫn đường AR',
              text:
                  'Chọn phòng hoặc địa điểm cần đến để mở camera AR và xem lối dẫn đường trên màn hình.',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
