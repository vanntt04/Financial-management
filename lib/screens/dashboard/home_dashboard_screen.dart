import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/api_service.dart';
import '../account/add_edit_account_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Load lần đầu nếu chưa có data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FinanceProvider>();
      if (provider.dashboard == null) {
        provider.loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer tự rebuild khi Provider thay đổi — không cần setState
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào,', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Người dùng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(child: Icon(Icons.person, size: 20)),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: provider.isDashboardLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.dashboardError != null
              ? _buildError(provider)
              : RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTotalBalanceCard(context, provider.dashboard?.totalBalance ?? 0),
                  const SizedBox(height: 16),
                  _buildMonthSummary(provider),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phân bổ quỹ (Jars)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => _openAddJar(context, provider),
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Thêm hũ mới',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if ((provider.dashboard?.accounts ?? []).isEmpty)
                    _buildEmptyJars(context)
                  else
                    ...(provider.dashboard?.accounts ?? [])
                        .map((a) => _buildJarItem(a, context, provider)),
                  if ((provider.dashboard?.recentTransactions ?? []).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Giao dịch gần đây',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...(provider.dashboard?.recentTransactions ?? []).map(_buildRecentTx),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Giữ nguyên UI gốc 100% ───────────────────────────────

  Widget _buildError(FinanceProvider provider) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 12),
      Text(provider.dashboardError ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          onPressed: () => provider.loadDashboard(),
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại')),
    ]),
  );

  Widget _buildTotalBalanceCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng tài sản',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${_formatAmount(balance)} VNĐ',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(FinanceProvider provider) {
    return Row(children: [
      Expanded(child: _summaryBox(
          'Thu tháng này',
          provider.dashboard?.monthlyIncome ?? 0,
          Colors.green,
          Icons.arrow_downward)),
      const SizedBox(width: 12),
      Expanded(child: _summaryBox(
          'Chi tháng này',
          provider.dashboard?.monthlyExpense ?? 0,
          Colors.red,
          Icons.arrow_upward)),
    ]);
  }

  Widget _summaryBox(String label, double amount, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ]),
          const SizedBox(height: 6),
          Text('${_formatAmount(amount)} đ',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ]),
      );

  Widget _buildJarItem(ApiAccount account, BuildContext context, FinanceProvider provider) {
    final isSaving = account.isGoalActive;
    return GestureDetector(
      onTap: () => _openEditJar(context, account, provider),
      child: Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSaving ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSaving ? Icons.savings_outlined : Icons.account_balance_wallet_outlined,
              color: isSaving ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(account.accountName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              if (account.allocationPercentage != null)
                Text('${account.allocationPercentage!.toInt()}% tổng quỹ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              if (isSaving && account.targetAmount != null)
                Text('Mục tiêu: ${_formatAmount(account.targetAmount!)} đ',
                    style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
            ]),
          ),
          Text('${_formatAmount(account.balance)} đ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
        ]),
      ),
    ),
    );
  }

  Widget _buildRecentTx(ApiTransaction tx) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    leading: CircleAvatar(
      backgroundColor: tx.isExpense ? Colors.red.shade50 : Colors.green.shade50,
      child: Icon(_iconFor(tx.categoryName), size: 20,
          color: tx.isExpense ? Colors.red : Colors.green),
    ),
    title: Text(tx.categoryName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    subtitle: Text(
      '${tx.accountName ?? ''} • ${tx.transactionDate.day}/${tx.transactionDate.month}',
      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
    ),
    trailing: Text(
      '${tx.isExpense ? '-' : '+'}${_formatAmount(tx.amount)} đ',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
          color: tx.isExpense ? Colors.red : Colors.green),
    ),
  );

  String _formatAmount(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'ăn uống': return Icons.restaurant;
      case 'mua sắm': return Icons.shopping_cart;
      case 'nhà cửa': return Icons.home;
      case 'học tập': return Icons.school;
      case 'di chuyển': return Icons.directions_car;
      case 'giải trí': return Icons.movie;
      case 'y tế': return Icons.health_and_safety;
      case 'lương': return Icons.attach_money;
      case 'thưởng': return Icons.card_giftcard;
      case 'tiền lãi': return Icons.savings;
      default: return Icons.swap_horiz;
    }
  }
  // ── Jar helpers ──────────────────────────────────────────

  Widget _buildEmptyJars(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAddJar(context, context.read<FinanceProvider>()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              style: BorderStyle.solid,
              width: 1.5),
        ),
        child: Column(children: [
          Icon(Icons.add_circle_outline,
              size: 40,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text('Chưa có hũ nào',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Nhấn để thêm hũ đầu tiên',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _openAddJar(BuildContext context, FinanceProvider provider) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const AddEditAccountScreen()),
    );
    if (result == true) provider.loadDashboard();
  }

  void _openEditJar(BuildContext context, ApiAccount account,
      FinanceProvider provider) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditAccountScreen(account: account)),
    );
    if (result == true) provider.loadDashboard();
  }

}
