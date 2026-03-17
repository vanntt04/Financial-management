import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account =
        ModalRoute.of(context)?.settings.arguments as AccountModel?;
    if (account == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin hũ')),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final isGoal = account.isGoalActive && account.targetAmount != null;
    final progress = isGoal
        ? (account.currentAmount / account.targetAmount!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              '/accounts/add-edit',
              arguments: account,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: account.type == 'SAVING'
                      ? [Colors.amber.shade600, Colors.amber.shade400]
                      : [scheme.primary, scheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        account.type == 'SAVING'
                            ? Icons.savings
                            : Icons.account_balance_wallet,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        account.type == 'SAVING' ? 'Tiết kiệm' : 'Chi tiêu',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Số dư hiện tại',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(account.currentAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phân bổ: ${account.percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Goal Section
            if (isGoal) ...[
              const SizedBox(height: 24),
              const Text('Mục tiêu tiết kiệm',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mục tiêu',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          CurrencyFormatter.format(account.targetAmount!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hiện tại',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          CurrencyFormatter.format(account.currentAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (account.targetDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hạn chót',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            () {
                              final d = DateTime.tryParse(account.targetDate!);
                              return d != null
                                  ? DateFormatter.toDisplay(d)
                                  : account.targetDate!;
                            }(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiến độ: ${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Còn thiếu: ${CurrencyFormatter.format(account.targetAmount! - account.currentAmount)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ],

            // Recent transactions placeholder
            const SizedBox(height: 24),
            const Text('Giao dịch gần đây',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Chưa có giao dịch nào',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
