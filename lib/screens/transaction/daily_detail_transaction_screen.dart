// lib/screens/transaction/daily_detail_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class DailyDetailTransactionScreen extends StatelessWidget {
  const DailyDetailTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final date = args?['date'] as DateTime? ?? DateTime.now();
    final txs = args?['transactions'] as List<TransactionModel>? ?? [];
    final income = txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _chip('Thu', income, Colors.green),
                const SizedBox(width: 12),
                _chip('Chi', expense, Colors.red),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Số dư ngày',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      CurrencyFormatter.format(income - expense),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: income >= expense ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: txs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_note_outlined,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('Không có giao dịch nào',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: txs.length,
                    itemBuilder: (context, i) {
                      final tx = txs[i];
                      final color = tx.isIncome ? Colors.green : Colors.red;
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, AppRoutes.transactionDetail,
                          arguments: tx,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  tx.isIncome
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.categoryName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    if (tx.note != null && tx.note!.isNotEmpty)
                                      Text(tx.note!,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500)),
                                    if (tx.accountName != null)
                                      Text(tx.accountName!,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade400)),
                                  ],
                                ),
                              ),
                              Text(
                                '${tx.isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: color),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          Text(CurrencyFormatter.format(amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
