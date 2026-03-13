import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Column(
        children: [
          // ── Colored top section ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 52, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Finance Manager',
                    style: TextStyle(color: scheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý tài chính thông minh',
                    style: TextStyle(color: scheme.onPrimary.withOpacity(0.75), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // ── White form section ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F7F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đăng nhập để tiếp tục',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email hoặc Số điện thoại',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forget-password'),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                        child: const Text('ĐĂNG NHẬP'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chưa có tài khoản?', style: TextStyle(color: Colors.grey.shade600)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Đăng ký ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
