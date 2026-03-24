// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/providers/auth_provider.dart';
import 'package:financial_management/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final notifEnabled = auth.userData?['notificationsEnabled'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primary.withOpacity(0.1),
                    backgroundImage: auth.photoURL != null
                        ? NetworkImage(auth.photoURL!)
                        : null,
                    child: auth.photoURL == null
                        ? Icon(Icons.person, color: scheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(auth.email,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.addEditProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Tài khoản'),
            _tile(icon: Icons.person_outline, label: 'Hồ sơ cá nhân',
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile)),
            _tile(icon: Icons.lock_outline, label: 'Đổi mật khẩu',
                onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword)),
            _tile(icon: Icons.category_outlined, label: 'Quản lý danh mục',
                onTap: () => Navigator.pushNamed(context, AppRoutes.category)),
            _tile(icon: Icons.savings_outlined, label: 'Quản lý hũ tiền',
                onTap: () => Navigator.pushNamed(context, AppRoutes.addEditAccount)),

            const SizedBox(height: 16),
            _sectionTitle('Tùy chọn'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Thông báo'),
                subtitle: const Text('Nhận nhắc nhở giao dịch'),
                value: notifEnabled,
                onChanged: (v) =>
                    context.read<AuthProvider>().updateProfile(
                        notificationsEnabled: v),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),
            _sectionTitle('Ứng dụng'),
            _tile(icon: Icons.bar_chart_outlined, label: 'Báo cáo thống kê',
                onTap: () => Navigator.pushNamed(context, AppRoutes.statisticsReports)),
            _tile(icon: Icons.flag_outlined, label: 'Mục tiêu tài chính',
                onTap: () => Navigator.pushNamed(context, AppRoutes.financialGoals)),
            _tile(icon: Icons.help_outline, label: 'Trợ giúp & Giới thiệu',
                onTap: () => Navigator.pushNamed(context, AppRoutes.aboutHelp)),

            const SizedBox(height: 16),
            // Logout
            Container(
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () => _logout(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: Text('Finance Manager v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.5)),
      );

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.grey.shade600),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      }
    }
  }
}
