import 'package:flutter/material.dart';
import '../../utils/currency_formatter.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = 'Tất cả';

  final List<Map<String, dynamic>> _transactions = [
    {'title': 'Ăn trưa', 'amount': -50000, 'date': '13/03/2026', 'jar': 'Chi tiêu thiết yếu', 'icon': Icons.restaurant},
    {'title': 'Đổ xăng', 'amount': -70000, 'date': '12/03/2026', 'jar': 'Chi tiêu thiết yếu', 'icon': Icons.local_gas_station},
    {'title': 'Lương tháng 2', 'amount': 15000000, 'date': '10/03/2026', 'jar': 'Tiết kiệm & Đầu tư', 'icon': Icons.attach_money},
    {'title': 'Xem phim', 'amount': -120000, 'date': '08/03/2026', 'jar': 'Giải trí & Cá nhân', 'icon': Icons.movie},
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _transactions
        .where((tx) => _selectedFilter == 'Tất cả' || tx['jar'] == _selectedFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(child: _buildSummaryChip('Tổng thu', 15000000, Colors.green.shade600, Icons.arrow_downward_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryChip('Tổng chi', 240000, Colors.red.shade400, Icons.arrow_upward_rounded)),
              ],
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: ['Tất cả', 'Chi tiêu thiết yếu', 'Tiết kiệm & Đầu tư', 'Giải trí & Cá nhân'].map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                    selectedColor: scheme.primaryContainer,
                    checkmarkColor: scheme.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? scheme.primary : Colors.grey.shade200),
                  ),
                );
              }).toList(),
            ),
          ),

          // Transaction list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tx = filtered[index];
                final isExpense = (tx['amount'] as int) < 0;
                final color = isExpense ? Colors.red.shade400 : Colors.green.shade600;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(tx['icon'] as IconData, color: color, size: 22),
                    ),
                    title: Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text('${tx['jar']} • ${tx['date']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    trailing: Text(
                      '${isExpense ? '-' : '+'}${formatCurrency((tx['amount'] as int).abs().toDouble())}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/transaction-detail'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(formatCurrency(amount), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
