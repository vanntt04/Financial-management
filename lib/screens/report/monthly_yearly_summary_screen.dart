import 'package:flutter/material.dart';

class MonthlyYearlySummaryScreen extends StatelessWidget {
  const MonthlyYearlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tổng kết tài chính'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Theo Tháng'),
              Tab(text: 'Theo Năm'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SummaryTab(title: 'Tháng 3 / 2026', income: 20000000, expense: 4500000),
            _SummaryTab(title: 'Năm 2026', income: 65000000, expense: 18000000),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final String title;
  final double income;
  final double expense;

  const _SummaryTab({required this.title, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final double net = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () {}),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoCard(context, 'Tổng Thu', income, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard(context, 'Tổng Chi', expense, Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thực lãnh (Thu - Chi)', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${net.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Chi tiêu nhiều nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          // Danh sách các danh mục tốn kém nhất
          ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.orange),
            title: const Text('Ăn uống'),
            trailing: const Text('2,000,000 đ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.purple),
            title: const Text('Mua sắm'),
            trailing: const Text('1,500,000 đ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} đ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}