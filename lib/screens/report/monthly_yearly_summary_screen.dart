import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class MonthlyYearlySummaryScreen extends StatelessWidget {
  const MonthlyYearlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tổng kết tài chính', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            tabs: const [Tab(text: 'Theo Tháng'), Tab(text: 'Theo Năm')],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
    final scheme = Theme.of(context).colorScheme;
    final double net = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Period navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Income / Expense cards
          Row(
            children: [
              Expanded(child: _buildInfoCard('Tổng Thu', income, Colors.green.shade600, Icons.arrow_downward_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard('Tổng Chi', expense, Colors.red.shade400, Icons.arrow_upward_rounded)),
            ],
          ),
          const SizedBox(height: 12),

          // Net card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_outlined, color: scheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Thực lãnh (Thu - Chi)', style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onPrimaryContainer)),
                  ],
                ),
                Text(
                  formatCurrency(net),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Top expenses
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Chi tiêu nhiều nhất', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                _buildTopExpenseItem(Icons.restaurant, 'Ăn uống', Colors.orange, 2000000),
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
                _buildTopExpenseItem(Icons.shopping_bag, 'Mua sắm', Colors.purple, 1500000),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(formatCurrency(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTopExpenseItem(IconData icon, String label, MaterialColor color, double amount) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
