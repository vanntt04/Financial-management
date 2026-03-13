import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Column(
        children: [
          // Green header with avatar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text('Hồ sơ của tôi', style: TextStyle(color: scheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.onPrimary.withOpacity(0.2),
                    child: Icon(Icons.person, size: 48, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 12),
                  Text('Nguyễn Văn A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: scheme.onPrimary)),
                  const SizedBox(height: 4),
                  Text('nguyenvana@gmail.com', style: TextStyle(fontSize: 14, color: scheme.onPrimary.withOpacity(0.75))),
                ],
              ),
            ),
          ),

          // White content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F7F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSection(context, [
                      _buildOption(context, Icons.edit_outlined, 'Chỉnh sửa thông tin', '/add-edit-profile', scheme),
                      _buildOption(context, Icons.lock_outline, 'Đổi mật khẩu', '/change-password', scheme),
                      _buildSwitchOption(context, Icons.fingerprint_outlined, 'Xác thực sinh trắc học', scheme),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection(context, [
                      _buildLogoutTile(context),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title, String route, ColorScheme scheme) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: scheme.primary, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildSwitchOption(BuildContext context, IconData icon, String title, ColorScheme scheme) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: scheme.primary, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(value: true, onChanged: (_) {}),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.logout, color: Colors.red.shade400, size: 18),
      ),
      title: Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade400)),
      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
    );
  }
}
