import 'package:flutter/material.dart';

class GoalProgressScreen extends StatelessWidget {
  const GoalProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double target = 30000000;
    const double saved = 5000000;
    const double progress = saved / target;

    return Scaffold(
      appBar: AppBar(title: const Text('Tiến độ Mục tiêu'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Colors.teal, child: Icon(Icons.laptop_mac, size: 40, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Mua Laptop mới', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Progress Bar
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200, height: 200,
                  child: CircularProgressIndicator(value: progress, strokeWidth: 12, backgroundColor: Colors.grey.shade200, color: Colors.teal),
                ),
                Column(
                  children: [
                    Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const Text('Đã hoàn thành', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tóm tắt số liệu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Đã tích lũy', saved, Colors.green),
                _buildStatBox('Cần thêm', target - saved, Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('NẠP THÊM TIỀN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text('${amount.toStringAsFixed(0)} đ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}