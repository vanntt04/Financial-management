import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Tùy chỉnh ứng dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Nhận thông báo'),
            subtitle: const Text('Nhắc nhở nhập liệu và báo cáo hàng ngày'),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: _notificationsEnabled,
            onChanged: (bool value) => setState(() => _notificationsEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Chế độ tối (Dark Mode)'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _darkModeEnabled,
            onChanged: (bool value) => setState(() => _darkModeEnabled = value),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Ngôn ngữ'),
            trailing: const Text('Tiếng Việt', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          const Divider(height: 32),
          const Text('Khác', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Trợ giúp & Phản hồi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/about-help'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Thông tin ứng dụng'),
            trailing: const Text('Phiên bản 1.0.0', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}