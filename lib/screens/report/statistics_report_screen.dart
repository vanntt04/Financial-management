import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class StatisticsReportScreen extends StatelessWidget {
  const StatisticsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/monthly-yearly'),
            icon: Icon(Icons.calendar_month_outlined, size: 18, color: scheme.primary),
            label: Text('Tổng kết', style: TextStyle(color: scheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: scheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng chi tiêu tháng 3', style: TextStyle(color: scheme.onPrimary.withOpacity(0.75), fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(4500000),
                        style: TextStyle(color: scheme.onPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: scheme.onPrimary.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(Icons.trending_down, color: scheme.onPrimary, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('Tỷ lệ sử dụng theo Hũ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 16),

            _buildJarProgressCard('Chi tiêu thiết yếu', 4000000, 7500000, Colors.orange.shade400),
            const SizedBox(height: 12),
            _buildJarProgressCard('Giải trí & Cá nhân', 500000, 3000000, Colors.purple.shade400),
            const SizedBox(height: 12),
            _buildJarProgressCard('Tiết kiệm & Đầu tư', 0, 4500000, Colors.teal.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildJarProgressCard(String title, double spent, double total, Color color) {
    final double percentage = total > 0 ? spent / total : 0;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: percentage, minHeight: 8, backgroundColor: Colors.grey.shade100, color: color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã dùng: ${formatCurrency(spent)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text('Định mức: ${formatCurrency(total)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
