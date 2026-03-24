import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/api_exception.dart';
import 'verify_forgot_otp_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}



class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.forgotPassword(email: _emailController.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyForgotOtpScreen(email: _emailController.text.trim()),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: Form(
          key: _formKey,
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
                'Nhập email của bạn, chúng tôi sẽ gửi mã OTP đặt lại mật khẩu.',
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('GỬI MÃ OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
