import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.themeNotifier});

  final ValueNotifier<bool> themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
          const Divider(),
          const ListTile(
            title: Text('camapus'),
            subtitle: Text('Bản đồ campus và điều hướng AR - phiên bản 1.0.0'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
