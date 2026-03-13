import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Nguyễn Văn A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('nguyenvana@gmail.com', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 32),

            // Các tùy chọn
            _buildProfileOption(context, Icons.edit_outlined, 'Chỉnh sửa thông tin', '/add-edit-profile'),
            _buildProfileOption(context, Icons.lock_outline, 'Đổi mật khẩu', '/change-password'),
            _buildProfileOption(context, Icons.security_outlined, 'Xác thực sinh trắc học', null, hasSwitch: true),
            const Divider(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                // Điều hướng về màn hình Login và xóa stack
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, String? route, {bool hasSwitch = false}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: hasSwitch
            ? Switch(value: true, onChanged: (val) {})
            : const Icon(Icons.chevron_right),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      ),
    );
  }
}