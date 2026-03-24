// lib/screens/goal/goal_progress_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/models/goal_model.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class GoalProgressScreen extends StatelessWidget {
  const GoalProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = ModalRoute.of(context)!.settings.arguments as GoalModel;
    final scheme = Theme.of(context).colorScheme;
    final color = goal.isCompleted ? Colors.green : scheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress circle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140, height: 140,
                          child: CircularProgressIndicator(
                            value: goal.progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(goal.progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(goal.isCompleted ? 'Hoàn thành!' : 'Tiến trình',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(goal.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                Expanded(child: _statCard('Đã tiết kiệm',
                    CurrencyFormatter.format(goal.currentAmount),
                    color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Còn lại',
                    CurrencyFormatter.format(goal.remaining),
                    color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('Mục tiêu',
                    CurrencyFormatter.format(goal.targetAmount),
                    color: scheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(
                    'Hạn chót',
                    goal.deadline != null
                        ? DateFormat('dd/MM/yyyy').format(goal.deadline!)
                        : 'Không giới hạn',
                    color: Colors.purple)),
              ],
            ),
            if (goal.note != null && goal.note!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ghi chú',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(goal.note!),
                  ],
                ),
              ),
            ],
            if (goal.daysLeft != null && !goal.isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goal.daysLeft! < 30
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: goal.daysLeft! < 30 ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Còn ${goal.daysLeft} ngày để đạt mục tiêu',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: goal.daysLeft! < 30
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          if (goal.daysLeft! > 0)
                            Text(
                              'Cần tiết kiệm thêm ~${CurrencyFormatter.format(goal.remaining / goal.daysLeft!)}/ngày',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
