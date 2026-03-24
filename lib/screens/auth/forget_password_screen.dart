// lib/screens/auth/forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/providers/auth_provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.forgotPassword(email: _emailCtrl.text.trim());
    if (mounted) {
      if (ok) {
        setState(() => _sent = true);
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.error!),
          backgroundColor: Colors.red,
        ));
        auth.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Quên mật khẩu',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess(scheme) : _buildForm(isLoading, scheme),
      ),
    );
  }

  Widget _buildForm(bool isLoading, ColorScheme scheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_reset_rounded,
                size: 64, color: scheme.primary),
          ),
          const SizedBox(height: 24),
          Text('Đặt lại mật khẩu',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Nhập email đã đăng ký. Chúng tôi sẽ gửi link đặt lại mật khẩu qua email.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập email';
              if (!v.contains('@')) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isLoading ? null : _send,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('GỬI EMAIL ĐẶT LẠI'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(ColorScheme scheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_rounded, size: 80, color: scheme.primary),
        const SizedBox(height: 24),
        Text('Email đã được gửi!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Kiểm tra hộp thư của ${_emailCtrl.text} để đặt lại mật khẩu.\nKiểm tra cả mục spam nếu không thấy.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quay lại đăng nhập'),
        ),
      ],
    );
  }
}
