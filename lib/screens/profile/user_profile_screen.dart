// lib/screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/providers/auth_provider.dart';
import 'package:financial_management/routes.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addEditProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar + name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: scheme.primary.withOpacity(0.1),
                    backgroundImage: auth.photoURL != null
                        ? NetworkImage(auth.photoURL!)
                        : null,
                    child: auth.photoURL == null
                        ? Icon(Icons.person, size: 48, color: scheme.primary)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(auth.displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(auth.email,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Đơn vị tiền: ${auth.currency}',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Menu items
            _MenuItem(
              icon: Icons.edit_outlined,
              label: 'Chỉnh sửa hồ sơ',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.addEditProfile),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              label: 'Đổi mật khẩu',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            _MenuItem(
              icon: Icons.category_outlined,
              label: 'Danh mục',
              onTap: () => Navigator.pushNamed(context, AppRoutes.category),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _MenuItem(
              icon: Icons.logout,
              label: 'Đăng xuất',
              color: Colors.red,
              onTap: () async {
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
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.grey.shade600),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: color)),
        trailing: Icon(Icons.chevron_right,
            size: 18, color: Colors.grey.shade400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Add Edit Profile ──────────────────────────────────────────────────────────

