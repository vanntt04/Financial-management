import 'package:flutter/material.dart';

import '../../services/finance_service.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _currentMonth;
  bool _isLoading = false;
  List<Map<String, dynamic>> _days = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await FinanceService.getCalendarReport(
        month: _currentMonth.month,
        year: _currentMonth.year,
      );
      if (!mounted) return;
      setState(() {
        _days = result;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tải được dữ liệu lịch giao dịch')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
      );
    });
    _loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = 'Tháng ${_currentMonth.month}, ${_currentMonth.year}';
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    bool hasTransaction(int day) {
      return _days.any((d) =>
          (d['day'] ?? d['date']) == day && (d['hasTransaction'] == true));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch giao dịch'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeMonth(-1)),
                Text(
                  monthLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeMonth(1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                  .map((day) => SizedBox(
                      width: 40,
                      child: Text(day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey))))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final hasTrans = hasTransaction(day);
                      final today = DateTime.now();
                      final isToday = day == today.day &&
                          _currentMonth.month == today.month &&
                          _currentMonth.year == today.year;

                      return GestureDetector(
                        onTap: hasTrans
                            ? () => Navigator.pushNamed(
                                  context,
                                  '/daily-detail',
                                  arguments: DateTime(_currentMonth.year,
                                      _currentMonth.month, day),
                                )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(day.toString(),
                                  style: TextStyle(
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              if (hasTrans)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
