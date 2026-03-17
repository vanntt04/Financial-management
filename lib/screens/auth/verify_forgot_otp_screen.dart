import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api_exception.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';

class VerifyForgotOtpScreen extends StatefulWidget {
  final String email;
  const VerifyForgotOtpScreen({super.key, required this.email});

  @override
  State<VerifyForgotOtpScreen> createState() => _VerifyForgotOtpScreenState();
}

class _VerifyForgotOtpScreenState extends State<VerifyForgotOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearOtp() {
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyOtp() async {
    final otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length != 6) {
      _showError('Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.verifyForgotOtp(
          email: widget.email, otpCode: otpCode);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            otpCode: otpCode,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
        _clearOtp();
      }
    } catch (_) {
      if (mounted) {
        _showError('Đã xảy ra lỗi, vui lòng thử lại.');
        _clearOtp();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      final message =
          await AuthService.forgotPassword(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      _clearOtp();
      _startCountdown();
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Đã xảy ra lỗi, vui lòng thử lại.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildOtpBox(int index, ColorScheme scheme) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => _onOtpChanged(value, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận OTP',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(Icons.mark_email_read_outlined, size: 64, color: scheme.primary),
            const SizedBox(height: 20),
            const Text(
              'Mã OTP đã gửi tới',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _buildOtpBox(i, scheme)),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('XÁC NHẬN'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Không nhận được mã?',
                    style: TextStyle(color: Colors.grey.shade600)),
                _countdown > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Gửi lại sau ${_countdown}s',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Gửi lại OTP',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
