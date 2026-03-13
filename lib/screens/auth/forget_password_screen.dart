import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.mark_email_read_outlined, size: 56, color: scheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Đặt lại mật khẩu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập email của bạn, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email đã đăng ký', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã gửi liên kết khôi phục đến ${_emailController.text}')),
                  );
                },
                child: const Text('GỬI LIÊN KẾT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
