import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class GoalProgressScreen extends StatelessWidget {
  const GoalProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double target = 30000000;
    const double saved = 5000000;
    const double progress = saved / target;

    return Scaffold(
      appBar: AppBar(title: const Text('Tiến độ Mục tiêu', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.laptop_mac, size: 36, color: Colors.indigo.shade400),
                  ),
                  const SizedBox(height: 12),
                  const Text('Mua Laptop mới', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Mục tiêu: ${formatCurrency(target)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  const SizedBox(height: 28),

                  // Circular progress
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 14,
                            backgroundColor: Colors.grey.shade100,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo.shade400),
                            ),
                            Text('Hoàn thành', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildStatBox('Đã tích lũy', saved, Colors.green.shade600)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('Cần thêm', target - saved, Colors.orange.shade500)),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('NẠP THÊM TIỀN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, double amount, Color color) {
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
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 6),
          Text(formatCurrency(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
