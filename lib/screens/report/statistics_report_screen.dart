import 'package:flutter/material.dart';

class StatisticsReportScreen extends StatelessWidget {
  const StatisticsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng quan tháng
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng chi tiêu tháng 3', style: TextStyle(color: Colors.black54)),
                        SizedBox(height: 8),
                        Text('4,500,000 đ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.trending_down, color: Colors.red, size: 40),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text('Tỷ lệ sử dụng theo Hũ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Biểu đồ thanh ngang cho từng hũ
            _buildJarProgressIndicator('Chi tiêu thiết yếu', 4000000, 7500000, Colors.orange),
            const SizedBox(height: 20),
            _buildJarProgressIndicator('Giải trí & Cá nhân', 500000, 3000000, Colors.purple),
            const SizedBox(height: 20),
            _buildJarProgressIndicator('Tiết kiệm & Đầu tư', 0, 4500000, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildJarProgressIndicator(String title, double spent, double total, Color color) {
    final double percentage = total > 0 ? spent / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${(percentage * 100).toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Đã dùng: ${spent.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Định mức: ${total.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}