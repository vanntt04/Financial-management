// lib/screens/dashboard/home_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/providers/auth_provider.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/models/account_model.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào,',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            Text(auth.displayName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: scheme.primary.withOpacity(0.1),
              backgroundImage: auth.photoURL != null
                  ? NetworkImage(auth.photoURL!)
                  : null,
              child: auth.photoURL == null
                  ? Icon(Icons.person, size: 20, color: scheme.primary)
                  : null,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TotalBalanceCard(
                  balance: finance.totalBalance, scheme: scheme),
              const SizedBox(height: 16),
              _MonthSummaryRow(
                  income: finance.monthlyIncome,
                  expense: finance.monthlyExpense),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Phân bổ quỹ (Jars)',
                action: IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: scheme.primary),
                  tooltip: 'Thêm hũ',
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.addEditAccount),
                ),
              ),
              if (finance.accounts.isEmpty)
                _EmptyJars(scheme: scheme)
              else
                ...finance.accounts.map((a) => _JarItem(account: a)),
              if (finance.recentTransactions.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Giao dịch gần đây',
                  action: TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.transactionList),
                    child: const Text('Xem tất cả'),
                  ),
                ),
                ...finance.recentTransactions
                    .map((t) => _RecentTxTile(tx: t)),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard(
      {required this.balance, required this.scheme});
  final double balance;
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: scheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng số dư',
              style: TextStyle(
                  color: scheme.onPrimary.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.format(balance),
              style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addTransaction),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm giao dịch'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onPrimary,
                    side: BorderSide(color: scheme.onPrimary.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.statisticsReports),
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Báo cáo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onPrimary,
                    side: BorderSide(color: scheme.onPrimary.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MonthSummaryRow extends StatelessWidget {
  const _MonthSummaryRow({required this.income, required this.expense});
  final double income, expense;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _SummaryChip(
                label: 'Thu nhập',
                amount: income,
                color: Colors.green,
                icon: Icons.arrow_downward_rounded)),
        const SizedBox(width: 12),
        Expanded(
            child: _SummaryChip(
                label: 'Chi tiêu',
                amount: expense,
                color: Colors.red,
                icon: Icons.arrow_upward_rounded)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(CurrencyFormatter.format(amount),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold)),
        if (action != null) action!,
      ],
    );
  }
}

class _EmptyJars extends StatelessWidget {
  const _EmptyJars({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('Chưa có hũ tiền nào',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addEditAccount),
            child: const Text('Tạo hũ tiền đầu tiên'),
          ),
        ],
      ),
    );
  }
}

class _JarItem extends StatelessWidget {
  const _JarItem({required this.account});
  final AccountModel account;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.savings_rounded, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (account.isGoalActive && account.targetAmount != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: account.progress,
                    backgroundColor: Colors.grey.shade100,
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(account.progress * 100).toStringAsFixed(0)}% — mục tiêu ${CurrencyFormatter.format(account.targetAmount!)}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          Text(CurrencyFormatter.format(account.balance),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
        ],
      ),
    );
  }
}

class _RecentTxTile extends StatelessWidget {
  const _RecentTxTile({required this.tx});
  final TransactionModel tx;
  @override
  Widget build(BuildContext context) {
    final isIncome = tx.isIncome;
    final color = isIncome ? Colors.green : Colors.red;
    return Container(
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
              isIncome
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
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (tx.note != null && tx.note!.isNotEmpty)
                  Text(tx.note!,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14),
              ),
              Text(
                DateFormat('dd/MM').format(tx.date),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
