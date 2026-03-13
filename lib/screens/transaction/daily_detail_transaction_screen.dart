import 'package:flutter/material.dart';

class DailyDetailTransactionScreen extends StatelessWidget {
  const DailyDetailTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('13 Tháng 3, 2026'), elevation: 0),
      body: Column(
        children: [
          // Bảng tóm tắt ngày
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBox('Thu nhập', '+0 đ', Colors.green),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildSummaryBox('Chi tiêu', '-120,000 đ', Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Danh sách giao dịch trong ngày
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.restaurant, color: Colors.white)),
                  title: const Text('Ăn trưa'),
                  subtitle: const Text('Chi tiêu thiết yếu'),
                  trailing: const Text('- 50,000 đ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pushNamed(context, '/transaction-detail'),
                ),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.local_gas_station, color: Colors.white)),
                  title: const Text('Đổ xăng'),
                  subtitle: const Text('Chi tiêu thiết yếu'),
                  trailing: const Text('- 70,000 đ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pushNamed(context, '/transaction-detail'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}