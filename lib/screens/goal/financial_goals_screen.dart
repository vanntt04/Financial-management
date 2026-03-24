// lib/screens/goal/financial_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/models/goal_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final goals = context.watch<FinanceProvider>().goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tài chính',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: goals.isEmpty
          ? _empty(context, scheme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, i) =>
                  _GoalCard(goal: goals[i]),
            ),
      floatingActionButton: goals.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm mục tiêu'),
            ),
    );
  }

  Widget _empty(BuildContext context, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Chưa có mục tiêu nào',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Tạo mục tiêu tài chính để theo dõi tiến trình tiết kiệm',
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo mục tiêu đầu tiên'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController(text: '0');
    final noteCtrl = TextEditingController();
    DateTime? deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Thêm mục tiêu tài chính',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tên mục tiêu',
                    prefixIcon: Icon(Icons.flag_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Số tiền mục tiêu (đ)',
                    prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Đã tiết kiệm (đ)',
                    prefixIcon: Icon(Icons.savings_outlined)),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setSt(() => deadline = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(deadline == null
                          ? 'Hạn chót (tùy chọn)'
                          : DateFormat('dd/MM/yyyy').format(deadline!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final target = double.tryParse(
                      targetCtrl.text.replaceAll(',', ''));
                  final current = double.tryParse(
                      currentCtrl.text.replaceAll(',', '')) ?? 0;
                  if (title.isEmpty || target == null || target <= 0) {
                    return;
                  }
                  await ctx.read<FinanceProvider>().createGoal(
                    title: title,
                    targetAmount: target,
                    currentAmount: current,
                    deadline: deadline,
                    note: noteCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('TẠO MỤC TIÊU'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});
  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = goal.isCompleted ? Colors.green : scheme.primary;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.goalProgress,
          arguments: goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    goal.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.flag_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (goal.deadline != null)
                        Text(
                          'Hạn: ${DateFormat('dd/MM/yyyy').format(goal.deadline!)}${goal.daysLeft != null ? ' (còn ${goal.daysLeft} ngày)' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'contribute') _contribute(context);
                    if (v == 'delete') _delete(context);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'contribute',
                        child: Text('Nạp tiền')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey.shade100,
                color: color,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CurrencyFormatter.format(goal.currentAmount),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600),
                ),
                Text(CurrencyFormatter.format(goal.targetAmount),
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contribute(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nạp tiền vào mục tiêu'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Số tiền nạp (đ)',
              prefixIcon: Icon(Icons.savings_outlined)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(
                  ctrl.text.replaceAll(',', ''));
              if (amount != null && amount > 0) {
                await context.read<FinanceProvider>().contributeToGoal(
                    goal.id, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa mục tiêu?'),
        content: Text('Xóa mục tiêu "${goal.title}"?'),
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
    if (ok == true && context.mounted) {
      context.read<FinanceProvider>().deleteGoal(goal.id);
    }
  }
}
