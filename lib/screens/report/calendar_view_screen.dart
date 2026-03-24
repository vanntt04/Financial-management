// lib/screens/report/calendar_view_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/providers/finance_provider.dart';
import 'package:financial_management/routes.dart';
import 'package:financial_management/utils/currency_formatter.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});
  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<DateTime, List<TransactionModel>> _buildEvents(List<TransactionModel> all) {
    final Map<DateTime, List<TransactionModel>> result = {};
    for (final tx in all.where((t) =>
    t.date.year == _focusedDay.year && t.date.month == _focusedDay.month)) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      result[key] ??= [];
      result[key]!.add(tx);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = context.watch<FinanceProvider>();
    final events = _buildEvents(finance.transactions);
    final selKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedEvents = events[selKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem theo lịch',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        // Month navigator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
                })),
            Text(DateFormat('MMMM yyyy', 'vi').format(_focusedDay),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  if (!next.isAfter(DateTime.now())) {
                    setState(() {
                      _focusedDay = next;
                      _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
                    });
                  }
                }),
          ]),
        ),

        // Calendar grid
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: _buildCalendarGrid(scheme, events),
        ),
        const Divider(height: 1),

        // Day summary bar
        if (selectedEvents.isNotEmpty) _buildDaySummary(selectedEvents),

        // Transaction list
        Expanded(
          child: selectedEvents.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.event_note_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('Không có giao dịch ngày ${DateFormat('dd/MM').format(_selectedDay)}',
                style: TextStyle(color: Colors.grey.shade500)),
          ]))
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedEvents.length,
              itemBuilder: (context, i) {
                final tx = selectedEvents[i];
                final color = tx.isIncome ? Colors.green : Colors.red;
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.transactionDetail, arguments: tx),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(
                              tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: color, size: 16)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tx.categoryName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        if (tx.note != null && tx.note!.isNotEmpty)
                          Text(tx.note!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ])),
                      Text('${tx.isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                    ]),
                  ),
                );
              }),
        ),
      ]),
    );
  }

  Widget _buildDaySummary(List<TransactionModel> txs) {
    final income = txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        if (income > 0) _chip('+${CurrencyFormatter.format(income)}', Colors.green),
        if (income > 0 && expense > 0) const SizedBox(width: 8),
        if (expense > 0) _chip('-${CurrencyFormatter.format(expense)}', Colors.red),
        const Spacer(),
        Text('${txs.length} giao dịch',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ]),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(
          color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildCalendarGrid(
      ColorScheme scheme, Map<DateTime, List<TransactionModel>> events) {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    const headers = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return Column(children: [
      Row(children: headers.map((h) => Expanded(child: Center(
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(h, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)))))).toList()),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, childAspectRatio: 1),
        itemCount: startWeekday + daysInMonth,
        itemBuilder: (context, index) {
          if (index < startWeekday) return const SizedBox.shrink();
          final day = index - startWeekday + 1;
          final date = DateTime(_focusedDay.year, _focusedDay.month, day);
          final isSelected = date.day == _selectedDay.day &&
              date.month == _selectedDay.month && date.year == _selectedDay.year;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month && date.day == DateTime.now().day;
          final dayEvents = events[date] ?? [];
          final hasIncome = dayEvents.any((t) => t.isIncome);
          final hasExpense = dayEvents.any((t) => t.isExpense);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: scheme.primary, width: 1.5) : null),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$day', style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : null)),
                if (hasIncome || hasExpense)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (hasIncome) Container(width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.green,
                            shape: BoxShape.circle)),
                    if (hasExpense) Container(width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                            color: isSelected ? Colors.white70 : Colors.red,
                            shape: BoxShape.circle)),
                  ]),
              ]),
            ),
          );
        },
      ),
    ]);
  }
}
