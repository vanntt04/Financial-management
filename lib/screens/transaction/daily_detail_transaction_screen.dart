import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class DailyDetailTransactionScreen extends StatelessWidget {
  const DailyDetailTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('13 Tháng 3, 2026', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Day summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryBox('Thu nhập', '+${formatCurrency(0)}', Colors.green.shade600, Icons.arrow_downward_rounded),
                ),
                Container(width: 1, height: 48, color: Colors.grey.shade100),
                Expanded(
                  child: _buildSummaryBox('Chi tiêu', '-${formatCurrency(120000)}', Colors.red.shade400, Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _buildTransactionItem(context, Icons.restaurant, 'Ăn trưa', 'Chi tiêu thiết yếu', 50000, scheme),
                const SizedBox(height: 10),
                _buildTransactionItem(context, Icons.local_gas_station, 'Đổ xăng', 'Chi tiêu thiết yếu', 70000, scheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String title, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 2),
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, IconData icon, String title, String subtitle, double amount, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.red.shade400, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: Text(
          '-${formatCurrency(amount)}',
          style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onTap: () => Navigator.pushNamed(context, '/transaction-detail'),
      ),
    );
  }
}
