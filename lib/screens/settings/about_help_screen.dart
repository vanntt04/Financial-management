import 'package:flutter/material.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & Phản hồi'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text('Finance Manager', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Phiên bản 1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),

          const Text('Câu hỏi thường gặp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildFaqItem('Cách tạo một hũ chi tiêu mới?', 'Bạn có thể tạo hũ mới trong phần cài đặt tài khoản.'),
          _buildFaqItem('Làm sao để xóa giao dịch?', 'Vuốt sang trái tại giao dịch bạn muốn xóa trong màn hình Danh sách.'),

          const Divider(height: 32),
          const Text('Liên hệ Hỗ trợ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Gửi email cho chúng tôi'),
            subtitle: const Text('support@financeapp.com'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Truy cập trang web'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: TextStyle(color: Colors.grey.shade700)),
        ),
      ],
    );
  }
}