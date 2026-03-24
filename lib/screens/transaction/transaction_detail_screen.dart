// lib/screens/transaction/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tx = ModalRoute.of(context)!.settings.arguments as TransactionModel;

    final isIncome = tx.isIncome;
    final color = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, tx),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(isIncome ? 'Thu nhập' : 'Chi tiêu',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row('Danh mục', tx.categoryName,
                      icon: Icons.category_outlined),
                  _divider(),
                  _row('Ngày',
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(tx.date),
                      icon: Icons.calendar_today_outlined),
                  if (tx.accountName != null) ...[
                    _divider(),
                    _row('Hũ tiền', tx.accountName!,
                        icon: Icons.savings_outlined),
                  ],
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    _divider(),
                    _row('Ghi chú', tx.note!,
                        icon: Icons.notes_outlined),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey.shade100, height: 1);

  Future<void> _confirmDelete(
      BuildContext context, TransactionModel tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text(
            'Giao dịch này sẽ bị xóa vĩnh viễn và số dư hũ sẽ được hoàn lại.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<FinanceProvider>().deleteTransaction(tx);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
