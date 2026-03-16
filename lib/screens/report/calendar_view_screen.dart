import 'package:flutter/material.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách các ngày có giao dịch trong tháng 3
    final List<int> daysWithTransactions = [5, 8, 10, 12, 13];

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch giao dịch'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                const Text('Tháng 3, 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ],
            ),
          ),
          // Tiêu đề các thứ trong tuần
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) =>
                  SizedBox(width: 40, child: Text(day, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
              ).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 31, // Số ngày trong tháng (tháng 3)
              itemBuilder: (context, index) {
                final day = index + 1;
                final hasTransaction = daysWithTransactions.contains(day);
                final isToday = day == 13; // Trùng với ngày hiện tại

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/daily-detail'),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isToday ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day.toString(), style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                        if (hasTransaction)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
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