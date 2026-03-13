import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập được truyền từ màn danh sách sang
    final bool isExpense = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
              child: Icon(Icons.restaurant, size: 40, color: isExpense ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 16),
            const Text('Ăn trưa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '- 50,000 đ',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isExpense ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 32),
            const Divider(),
            _buildDetailRow('Ngày giao dịch', '13/03/2026 12:30'),
            const Divider(),
            _buildDetailRow('Trừ vào Quỹ/Hũ', 'Chi tiêu thiết yếu'),
            const Divider(),
            _buildDetailRow('Danh mục', 'Ăn uống'),
            const Divider(),
            _buildDetailRow('Ghi chú', 'Ăn bún chả cùng đồng nghiệp'),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}