import 'package:flutter/material.dart';
import '../../core/api_exception.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpController      = TextEditingController();
  final _newPwController    = TextEditingController();
  final _confirmPwController = TextEditingController();
  bool _isLoading = false;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  void dispose() {
    _otpController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final otp     = _otpController.text.trim();
    final newPw   = _newPwController.text;
    final confirm = _confirmPwController.text;

    if (otp.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _showError('Vui lòng điền đầy đủ thông tin');
      return;
    }
    if (newPw != confirm) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final msg = await AuthService.resetPassword(
        email:           widget.email,
        otpCode:         otp,
        newPassword:     newPw,
        confirmPassword: confirm,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (r) => false);
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
    return Scaffold(
      appBar: AppBar(
          title: const Text('Đặt lại mật khẩu',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mã OTP đã gửi tới\n${widget.email}',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Mã OTP (6 chữ số)',
                  prefixIcon: Icon(Icons.lock_open_outlined)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPwController,
              obscureText: _obsNew,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obsNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obsNew = !_obsNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPwController,
              obscureText: _obsConfirm,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obsConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obsConfirm = !_obsConfirm),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _reset,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('ĐẶT LẠI MẬT KHẨU'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
