// lib/screens/transaction/transaction_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'ALL';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();

    final txs = finance.transactions.where((t) {
      if (_filter == 'INCOME' && !t.isIncome) return false;
      if (_filter == 'EXPENSE' && !t.isExpense) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return t.categoryName.toLowerCase().contains(q) ||
            (t.note?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in txs) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped[key] ??= [];
      grouped[key]!.add(tx);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.calendarView),
            tooltip: 'Xem lịch',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm giao dịch...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips
                Row(
                  children: [
                    _chip('Tất cả', 'ALL', scheme),
                    const SizedBox(width: 8),
                    _chip('Thu nhập', 'INCOME', scheme),
                    const SizedBox(width: 8),
                    _chip('Chi tiêu', 'EXPENSE', scheme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: txs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Không có giao dịch nào',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final dayTxs = grouped[key]!;
                final date = DateTime.parse(key);
                final dayIncome = dayTxs
                    .where((t) => t.isIncome)
                    .fold(0.0, (s, t) => s + t.amount);
                final dayExpense = dayTxs
                    .where((t) => t.isExpense)
                    .fold(0.0, (s, t) => s + t.amount);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.dailyDetail,
                          arguments: {'date': date, 'transactions': dayTxs}),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('EEE, dd/MM/yyyy', 'vi').format(date),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                  fontSize: 13),
                            ),
                            const Spacer(),
                            if (dayIncome > 0)
                              Text('+${CurrencyFormatter.format(dayIncome)}',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            if (dayIncome > 0 && dayExpense > 0)
                              const SizedBox(width: 6),
                            if (dayExpense > 0)
                              Text('-${CurrencyFormatter.format(dayExpense)}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    ...dayTxs.map((tx) => _TxTile(
                        tx: tx,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.transactionDetail,
                            arguments: tx))),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chip(String label, String value, ColorScheme scheme) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey.shade600,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx, required this.onTap});
  final TransactionModel tx;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;
    final color = isIncome ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: onTap,
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
                color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    Text(tx.note!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis),
                  if (tx.accountName != null)
                    Text(tx.accountName!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
