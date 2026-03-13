import 'package:flutter/material.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // Bộ lọc tạm thời
  String _selectedFilter = 'Tất cả';

  // Dữ liệu giả lập
  final List<Map<String, dynamic>> _transactions = [
    {'title': 'Ăn trưa', 'amount': -50000, 'date': '13/03/2026', 'jar': 'Chi tiêu thiết yếu', 'icon': Icons.restaurant},
    {'title': 'Đổ xăng', 'amount': -70000, 'date': '12/03/2026', 'jar': 'Chi tiêu thiết yếu', 'icon': Icons.local_gas_station},
    {'title': 'Lương tháng 2', 'amount': 15000000, 'date': '10/03/2026', 'jar': 'Tiết kiệm & Đầu tư', 'icon': Icons.attach_money},
    {'title': 'Xem phim', 'amount': -120000, 'date': '08/03/2026', 'jar': 'Giải trí & Cá nhân', 'icon': Icons.movie},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['Tất cả', 'Chi tiêu thiết yếu', 'Tiết kiệm & Đầu tư', 'Giải trí & Cá nhân'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          // Transaction List
          Expanded(
            child: ListView.separated(
              itemCount: _transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isExpense = tx['amount'] < 0;

                // Lọc cơ bản
                if (_selectedFilter != 'Tất cả' && tx['jar'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                    child: Icon(
                      tx['icon'],
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${tx['jar']} • ${tx['date']}'),
                  trailing: Text(
                    '${isExpense ? '' : '+'}${tx['amount']} đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  onTap: () {
                    // Navigate tới TransactionDetailScreen
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}