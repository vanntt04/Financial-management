import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obsCurrent = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildPasswordField('Mật khẩu hiện tại', _obsCurrent, () => setState(() => _obsCurrent = !_obsCurrent)),
            const SizedBox(height: 16),
            _buildPasswordField('Mật khẩu mới', _obsNew, () => setState(() => _obsNew = !_obsNew)),
            const SizedBox(height: 16),
            _buildPasswordField('Xác nhận mật khẩu mới', _obsConfirm, () => setState(() => _obsConfirm = !_obsConfirm)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CẬP NHẬT MẬT KHẨU', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, bool isObscure, VoidCallback toggle) {
    return TextFormField(
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}