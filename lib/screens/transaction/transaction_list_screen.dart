import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/api_service.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = 'Tất cả';

  final _filterMap = {
    'Tất cả':  'ALL',
    'Chi tiêu': 'EXPENSE',
    'Thu nhập': 'INCOME',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadTransactions();
    });
  }

  Future<void> _delete(BuildContext context, ApiTransaction tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: Text('Xóa "${tx.categoryName}"?\nSố dư tài khoản sẽ được hoàn lại.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    // Provider tự reload Dashboard + TransactionList sau khi xóa
    final success = await context.read<FinanceProvider>()
        .deleteTransaction(tx.transactionId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Đã xóa giao dịch' : 'Xóa thất bại'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  String _formatAmount(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch sử giao dịch'),
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.loadTransactions(
                    type: _filterMap[_selectedFilter] ?? 'ALL'),
              ),
            ],
          ),
          body: Column(children: [

            // ── Filter Tabs — giữ nguyên UI gốc ─────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: _filterMap.keys.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                        // Provider tự reload với filter mới
                        provider.loadTransactions(
                            type: _filterMap[filter] ?? 'ALL');
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Transaction List ──────────────────────────────
            Expanded(
              child: provider.isTransactionsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.transactionsError != null
                  ? _buildError(provider)
                  : provider.transactions.isEmpty
                  ? const Center(
                  child: Text('Không có giao dịch',
                      style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                onRefresh: () => provider.loadTransactions(
                    type: _filterMap[_selectedFilter] ?? 'ALL'),
                child: ListView.separated(
                  itemCount: provider.transactions.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1),
                  itemBuilder: (ctx, i) =>
                      _buildTile(ctx, provider.transactions[i]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildError(FinanceProvider provider) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 12),
      Text(provider.transactionsError ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          onPressed: () => provider.loadTransactions(),
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại')),
    ]),
  );

  // ── Giữ nguyên UI gốc 100% + thêm vuốt trái xóa ─────────
  Widget _buildTile(BuildContext context, ApiTransaction tx) {
    final isExpense = tx.isExpense;
    final dateStr =
        '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}';

    return Dismissible(
      key: Key('tx_${tx.transactionId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _delete(context, tx);
        return false; // Provider tự reload, không cần Dismissible xóa item
      },
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor:
          isExpense ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(
            _iconFor(tx.categoryName),
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(tx.categoryName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${isExpense ? 'Chi tiêu' : 'Thu nhập'} • ${tx.accountName ?? ''} • $dateStr'),
        trailing: Text(
          '${isExpense ? '-' : '+'}${_formatAmount(tx.amount)} đ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        onTap: () {},
      ),
    );
  }

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
}
