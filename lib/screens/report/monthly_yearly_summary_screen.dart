// lib/screens/report/monthly_yearly_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class MonthlyYearlySummaryScreen extends StatefulWidget {
  const MonthlyYearlySummaryScreen({super.key});
  @override
  State<MonthlyYearlySummaryScreen> createState() => _MonthlyYearlySummaryScreenState();
}

class _MonthlyYearlySummaryScreenState extends State<MonthlyYearlySummaryScreen> {
  int _selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> _buildMonthlyData(List<TransactionModel> all, int year) {
    final monthly = List.generate(12, (i) => <String, dynamic>{
      'month': i + 1, 'income': 0.0, 'expense': 0.0, 'saving': 0.0,
    });
    for (final tx in all.where((t) => t.date.year == year)) {
      final m = tx.date.month - 1;
      if (tx.isIncome) {
        monthly[m]['income'] = (monthly[m]['income'] as double) + tx.amount;
      } else {
        monthly[m]['expense'] = (monthly[m]['expense'] as double) + tx.amount;
      }
    }
    for (final m in monthly) {
      m['saving'] = (m['income'] as double) - (m['expense'] as double);
    }
    return monthly;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();
    final monthly = _buildMonthlyData(finance.transactions, _selectedYear);
    final yearIncome = monthly.fold(0.0, (s, m) => s + (m['income'] as double));
    final yearExpense = monthly.fold(0.0, (s, m) => s + (m['expense'] as double));
    final yearSaving = yearIncome - yearExpense;
    const months = ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng kết tháng/năm',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Year picker
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _selectedYear--)),
            Text('Năm $_selectedYear',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _selectedYear >= DateTime.now().year
                    ? null : () => setState(() => _selectedYear++)),
          ]),
          const SizedBox(height: 16),

          // Yearly summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text('Tổng kết $_selectedYear',
                  style: TextStyle(color: scheme.onPrimary.withOpacity(0.8))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _yStat('Thu nhập', yearIncome, Colors.greenAccent, scheme),
                _yStat('Chi tiêu', yearExpense, Colors.redAccent, scheme),
                _yStat('Tiết kiệm', yearSaving, Colors.cyanAccent, scheme),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // Bar chart
          const Text('Biểu đồ thu-chi theo tháng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: _MonthlyBarChart(monthly: monthly),
          ),
          const SizedBox(height: 24),

          // Table header
          const Text('Chi tiết từng tháng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const SizedBox(width: 32),
              Expanded(child: Text('Thu', style: TextStyle(
                  fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Chi', style: TextStyle(
                  fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Tiết kiệm', textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
            ]),
          ),

          // Monthly rows
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: List.generate(12, (i) {
              final m = monthly[i];
              final inc = m['income'] as double;
              final exp = m['expense'] as double;
              final sav = m['saving'] as double;
              final isCurrent = _selectedYear == DateTime.now().year &&
                  (i + 1) == DateTime.now().month;
              final hasData = inc > 0 || exp > 0;
              return Container(
                decoration: BoxDecoration(
                    color: isCurrent ? scheme.primary.withOpacity(0.05) : null,
                    border: i < 11
                        ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                        : null),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  SizedBox(width: 32,
                      child: Text(months[i], style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? scheme.primary : Colors.grey.shade600,
                          fontSize: 13))),
                  Expanded(child: Text(
                      hasData ? CurrencyFormatter.format(inc) : '—',
                      style: TextStyle(
                          color: hasData ? Colors.green.shade700 : Colors.grey.shade300,
                          fontSize: 12))),
                  Expanded(child: Text(
                      hasData ? CurrencyFormatter.format(exp) : '—',
                      style: TextStyle(
                          color: hasData ? Colors.red.shade700 : Colors.grey.shade300,
                          fontSize: 12))),
                  Expanded(child: Text(
                      hasData ? CurrencyFormatter.format(sav) : '—',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12,
                          color: !hasData ? Colors.grey.shade300
                              : sav >= 0 ? Colors.green : Colors.red))),
                ]),
              );
            })),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legend('Thu nhập', Colors.green),
            const SizedBox(width: 20),
            _legend('Chi tiêu', Colors.red),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _yStat(String label, double amount, Color color, ColorScheme scheme) {
    return Column(children: [
      Text(label, style: TextStyle(color: scheme.onPrimary.withOpacity(0.7), fontSize: 11)),
      const SizedBox(height: 4),
      FittedBox(child: Text(CurrencyFormatter.format(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
    ]);
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.monthly});
  final List<Map<String, dynamic>> monthly;

  @override
  Widget build(BuildContext context) {
    final maxVal = monthly.fold(0.0, (m, e) =>
        [m, e['income'] as double, e['expense'] as double]
            .reduce((a, b) => a > b ? a : b));

    if (maxVal <= 0) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bar_chart_outlined, size: 40, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey.shade400)),
      ]));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(12, (i) {
        final m = monthly[i];
        final incRatio = ((m['income'] as double) / maxVal).clamp(0.0, 1.0);
        final expRatio = ((m['expense'] as double) / maxVal).clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (incRatio > 0)
                Flexible(
                  flex: (incRatio * 100).round().clamp(1, 100),
                  child: Container(decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.75),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))),
                )
              else const Spacer(),
              const SizedBox(height: 2),
              if (expRatio > 0)
                Flexible(
                  flex: (expRatio * 100).round().clamp(1, 100),
                  child: Container(decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.75),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))),
                )
              else const Spacer(),
              const SizedBox(height: 4),
              Text('${i + 1}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ]),
          ),
        );
      }),
    );
  }
}
