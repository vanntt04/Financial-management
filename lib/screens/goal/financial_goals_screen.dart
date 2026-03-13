import 'package:flutter/material.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final goals = [
      {'name': 'Quỹ khẩn cấp', 'target': 50000000, 'saved': 25000000, 'icon': Icons.health_and_safety},
      {'name': 'Mua Laptop mới', 'target': 30000000, 'saved': 5000000, 'icon': Icons.laptop_mac},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tài chính'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final double target = (goal['target'] as int).toDouble();
          final double saved = (goal['saved'] as int).toDouble();
          final double progress = saved / target;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(goal['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Mục tiêu: ${(target).toStringAsFixed(0)} đ', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => Navigator.pushNamed(context, '/goal-progress')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đã gom: ${(saved).toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${(progress * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Thêm mục tiêu'),
      ),
    );
  }
}