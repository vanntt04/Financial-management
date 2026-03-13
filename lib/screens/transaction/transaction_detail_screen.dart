import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isExpense = true;
    final color = isExpense ? Colors.red.shade400 : Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.restaurant, size: 32, color: color),
                  ),
                  const SizedBox(height: 14),
                  const Text('Ăn trưa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '-${formatCurrency(50000)}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today_outlined, 'Ngày giao dịch', '13/03/2026 12:30', scheme),
                  _buildDivider(),
                  _buildDetailRow(Icons.account_balance_wallet_outlined, 'Quỹ / Hũ', 'Chi tiêu thiết yếu', scheme),
                  _buildDivider(),
                  _buildDetailRow(Icons.category_outlined, 'Danh mục', 'Ăn uống', scheme),
                  _buildDivider(),
                  _buildDetailRow(Icons.notes_outlined, 'Ghi chú', 'Ăn bún chả cùng đồng nghiệp', scheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 48, color: Colors.grey.shade100);
}
