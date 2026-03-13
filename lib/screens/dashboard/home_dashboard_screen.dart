import 'package:flutter/material.dart';
import '../../models/account.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập đã cập nhật theo Model mới (Dùng Account, Jar và id là int)
    final myAccount = Account(
      id: 1,
      totalBalance: 20000000,
      jars: [
        Jar(id: 1, name: 'Chi tiêu thiết yếu', percentage: 0.5, currentAmount: 10000000, type: 'SPENDING'),
        Jar(id: 2, name: 'Tiết kiệm dài hạn', percentage: 0.3, currentAmount: 6000000, type: 'SAVING'),
        Jar(id: 3, name: 'Đầu tư & Giải trí', percentage: 0.2, currentAmount: 4000000, type: 'SPENDING'),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào,', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(child: Icon(Icons.person, size: 20)),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTotalBalanceCard(context, myAccount.totalBalance),
            const SizedBox(height: 24),
            const Text('Phân bổ quỹ (Jars)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Map danh sách jars từ account model
            ...myAccount.jars.map((jar) => _buildJarItem(jar)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Đã sửa cảnh báo .withOpacity thành .withValues(alpha: 0.3)
          BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng tài sản', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Đổi kiểu tham số từ FundJar thành Jar
  Widget _buildJarItem(Jar jar) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: jar.type == 'SAVING' ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                jar.type == 'SAVING' ? Icons.savings_outlined : Icons.account_balance_wallet_outlined,
                color: jar.type == 'SAVING' ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jar.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${(jar.percentage * 100).toInt()}% tổng quỹ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '${jar.currentAmount.toStringAsFixed(0)} đ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}