// lib/screens/settings/about_help_screen.dart
import 'package:flutter/material.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp & Giới thiệu',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        size: 48, color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 12),
                  Text('Finance Manager',
                      style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Phiên bản 1.0.0',
                      style: TextStyle(
                          color: scheme.onPrimary.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Text('Quản lý tài chính cá nhân thông minh',
                      style: TextStyle(
                          color: scheme.onPrimary.withOpacity(0.8),
                          fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Tính năng chính',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._features.map((f) => _FeatureTile(
                icon: f['icon'] as IconData,
                title: f['title'] as String,
                desc: f['desc'] as String)),

            const SizedBox(height: 24),
            const Text('Hướng dẫn sử dụng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._guides.asMap().entries.map((e) => _GuideTile(
                step: e.key + 1, text: e.value as String)),

            const SizedBox(height: 24),
            const Text('FAQ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._faqs.map((f) => _FaqTile(
                q: f['q'] as String, a: f['a'] as String)),

            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.email_outlined,
                      color: Colors.blue, size: 28),
                  const SizedBox(height: 8),
                  const Text('Cần hỗ trợ thêm?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('support@financemanager.app',
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static const _features = [
    {'icon': Icons.dashboard_rounded, 'title': 'Dashboard tổng quan',
      'desc': 'Xem tổng số dư, thu nhập và chi tiêu tháng hiện tại'},
    {'icon': Icons.receipt_long_rounded, 'title': 'Quản lý giao dịch',
      'desc': 'Thêm, xem và xóa giao dịch thu nhập & chi tiêu'},
    {'icon': Icons.savings_rounded, 'title': 'Hệ thống hũ tiền (Jars)',
      'desc': 'Phân bổ tài chính theo phương pháp 6 hũ tiền'},
    {'icon': Icons.flag_rounded, 'title': 'Mục tiêu tài chính',
      'desc': 'Đặt và theo dõi tiến trình tiết kiệm cho các mục tiêu'},
    {'icon': Icons.bar_chart_rounded, 'title': 'Báo cáo thống kê',
      'desc': 'Phân tích chi tiêu theo danh mục, theo tháng và năm'},
    {'icon': Icons.calendar_month_rounded, 'title': 'Xem theo lịch',
      'desc': 'Theo dõi giao dịch theo từng ngày trên lịch'},
  ];

  static const _guides = [
    'Đăng ký tài khoản với email và mật khẩu của bạn.',
    'Tạo các hũ tiền để phân bổ ngân sách (VD: Chi tiêu, Tiết kiệm, Học tập...).',
    'Thêm giao dịch mỗi khi có thu nhập hoặc chi tiêu.',
    'Xem báo cáo để hiểu rõ thói quen tài chính của mình.',
    'Đặt mục tiêu tiết kiệm và theo dõi tiến trình mỗi tháng.',
  ];

  static const _faqs = [
    {
      'q': 'Dữ liệu của tôi có an toàn không?',
      'a': 'Dữ liệu được lưu trữ an toàn trên Firebase Cloud Firestore với mã hóa end-to-end. Chỉ bạn mới có thể truy cập dữ liệu của mình.',
    },
    {
      'q': 'Tôi có thể dùng trên nhiều thiết bị không?',
      'a': 'Có! Dữ liệu được đồng bộ real-time qua Firebase nên bạn có thể đăng nhập trên nhiều thiết bị và luôn có dữ liệu mới nhất.',
    },
    {
      'q': 'Làm thế nào để đổi mật khẩu?',
      'a': 'Vào Cài đặt > Đổi mật khẩu, nhập mật khẩu hiện tại và mật khẩu mới.',
    },
    {
      'q': 'Tôi quên mật khẩu thì phải làm gì?',
      'a': 'Ở màn hình đăng nhập, nhấn "Quên mật khẩu?" và nhập email. Chúng tôi sẽ gửi link đặt lại mật khẩu qua email.',
    },
  ];
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile(
      {required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title, desc;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.step, required this.text});
  final int step;
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text('$step',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.q, required this.a});
  final String q, a;
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(widget.q,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Icon(_expanded
            ? Icons.expand_less
            : Icons.expand_more),
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(widget.a,
                style: TextStyle(
                    color: Colors.grey.shade600, height: 1.5)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
