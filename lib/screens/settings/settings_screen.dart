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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Tùy chỉnh'),
          const SizedBox(height: 8),
          _buildCard([
            SwitchListTile(
              title: const Text('Nhận thông báo', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Nhắc nhở nhập liệu hàng ngày', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              secondary: _buildIconBox(Icons.notifications_active_outlined, scheme),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            Divider(height: 1, indent: 72, color: Colors.grey.shade100),
            SwitchListTile(
              title: const Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.w600)),
              secondary: _buildIconBox(Icons.dark_mode_outlined, scheme),
              value: _darkModeEnabled,
              onChanged: (v) => setState(() => _darkModeEnabled = v),
            ),
            Divider(height: 1, indent: 72, color: Colors.grey.shade100),
            ListTile(
              leading: _buildIconBox(Icons.language_outlined, scheme),
              title: const Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('Tiếng Việt', style: TextStyle(color: Colors.grey.shade500)),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('Khác'),
          const SizedBox(height: 8),
          _buildCard([
            ListTile(
              leading: _buildIconBox(Icons.help_outline, scheme),
              title: const Text('Trợ giúp & Phản hồi', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
              onTap: () => Navigator.pushNamed(context, '/about-help'),
            ),
            Divider(height: 1, indent: 72, color: Colors.grey.shade100),
            ListTile(
              leading: _buildIconBox(Icons.info_outline, scheme),
              title: const Text('Thông tin ứng dụng', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('v1.0.0', style: TextStyle(color: Colors.grey.shade500)),
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIconBox(IconData icon, ColorScheme scheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: scheme.primary, size: 18),
    );
  }
}
