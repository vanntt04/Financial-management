import 'package:flutter/material.dart';
import '../../core/api_exception.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Vui lòng nhập email');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.forgotPassword(email: email);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: email)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Quên mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.mark_email_read_outlined,
                  size: 56, color: scheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Đặt lại mật khẩu',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập email của bạn để nhận mã OTP đặt lại mật khẩu.',
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email đã đăng ký',
                  prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('GỬI MÃ OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
