import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goals = [
      {'name': 'Quỹ khẩn cấp', 'target': 50000000, 'saved': 25000000, 'icon': Icons.health_and_safety, 'color': Colors.teal},
      {'name': 'Mua Laptop mới', 'target': 30000000, 'saved': 5000000, 'icon': Icons.laptop_mac, 'color': Colors.indigo},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tài chính', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final double target = (goal['target'] as int).toDouble();
          final double saved = (goal['saved'] as int).toDouble();
          final double progress = saved / target;
          final color = goal['color'] as MaterialColor;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(14)),
                      child: Icon(goal['icon'] as IconData, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Mục tiêu: ${formatCurrency(target)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/goal-progress'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('Chi tiết', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey.shade100, color: color),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đã gom: ${formatCurrency(saved)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Thêm mục tiêu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
