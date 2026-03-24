// lib/screens/report/statistics_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class StatisticsReportScreen extends StatefulWidget {
  const StatisticsReportScreen({super.key});
  @override
  State<StatisticsReportScreen> createState() => _StatisticsReportScreenState();
}

class _StatisticsReportScreenState extends State<StatisticsReportScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _prevMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
  });

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (!next.isAfter(DateTime.now())) setState(() => _selectedMonth = next);
  }

  List<TransactionModel> _filterByMonth(List<TransactionModel> all) {
    return all.where((tx) =>
    tx.date.year == _selectedMonth.year &&
        tx.date.month == _selectedMonth.month).toList();
  }

  Map<String, double> _groupByCategory(List<TransactionModel> txs, String type) {
    final Map<String, double> result = {};
    for (final tx in txs.where((t) => t.type == type)) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return Map.fromEntries(
        result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();
    final monthTxs = _filterByMonth(finance.transactions);

    final income = monthTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = monthTxs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    final saving = income - expense;

    final expenseByCategory = _groupByCategory(monthTxs, 'EXPENSE');
    final incomeByCategory = _groupByCategory(monthTxs, 'INCOME');
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.monthlyYearly),
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
            // Month picker
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
                  Text('Tháng ${_selectedMonth.month}/${_selectedMonth.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isCurrentMonth ? null : _nextMonth,
                    color: isCurrentMonth ? Colors.grey.shade300 : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: scheme.primary.withOpacity(0.25),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tháng ${_selectedMonth.month}/${_selectedMonth.year}',
                      style: TextStyle(color: scheme.onPrimary.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem('Thu nhập', income, Colors.greenAccent, scheme),
                      _summaryItem('Chi tiêu', expense, Colors.redAccent, scheme),
                      _summaryItem('Tiết kiệm', saving, Colors.cyanAccent, scheme),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Empty state
            if (monthTxs.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Icon(Icons.bar_chart_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Chưa có giao dịch tháng này',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('Thêm giao dịch để xem thống kê',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 24),
            ],

            // Expense breakdown
            if (expenseByCategory.isNotEmpty) ...[
              const Text('Chi tiêu theo danh mục',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _CategoryBreakdown(data: expenseByCategory, color: Colors.red,
                  total: expense <= 0 ? 1 : expense),
              const SizedBox(height: 24),
            ],

            // Income breakdown
            if (incomeByCategory.isNotEmpty) ...[
              const Text('Thu nhập theo danh mục',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _CategoryBreakdown(data: incomeByCategory, color: Colors.green,
                  total: income <= 0 ? 1 : income),
              const SizedBox(height: 24),
            ],

            // Quick links
            const Text('Xem thêm',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _QuickLinkCard(
                  icon: Icons.calendar_today_rounded, label: 'Xem theo lịch',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.calendarView))),
              const SizedBox(width: 12),
              Expanded(child: _QuickLinkCard(
                  icon: Icons.summarize_rounded, label: 'Tổng kết tháng/năm',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.monthlyYearly))),
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color, ColorScheme scheme) {
    return Column(children: [
      Text(label, style: TextStyle(color: scheme.onPrimary.withOpacity(0.7), fontSize: 11)),
      const SizedBox(height: 4),
      FittedBox(child: Text(CurrencyFormatter.format(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15))),
    ]);
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.data, required this.color, required this.total});
  final Map<String, double> data;
  final Color color;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: data.entries.map((e) {
        final pct = total > 0 ? (e.value / total).clamp(0.0, 1.0) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(e.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text('${CurrencyFormatter.format(e.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
            const SizedBox(height: 6),
            LinearProgressIndicator(
                value: pct, backgroundColor: Colors.grey.shade100, color: color,
                borderRadius: BorderRadius.circular(4), minHeight: 8),
          ]),
        );
      }).toList()),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
