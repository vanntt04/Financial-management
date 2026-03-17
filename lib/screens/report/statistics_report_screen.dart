import 'package:flutter/material.dart';

import '../../services/finance_service.dart';
import '../../utils/currency_formatter.dart';

class StatisticsReportScreen extends StatefulWidget {
  const StatisticsReportScreen({super.key});

  @override
  State<StatisticsReportScreen> createState() => _StatisticsReportScreenState();
}

class _StatisticsReportScreenState extends State<StatisticsReportScreen> {
  late DateTime _selectedMonth;
  bool _isLoading = false;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await FinanceService.getMonthlyReportSummary(
        month: _selectedMonth.month,
        year: _selectedMonth.year,
      );
      if (!mounted) return;
      setState(() {
        _summary = result;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tải được dữ liệu báo cáo')),
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
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final monthLabel = 'Tháng ${_selectedMonth.month}, ${_selectedMonth.year}';

    final totalExpense = (_summary?['totalExpense'] ?? 0).toDouble();
    final jars = (_summary?['jars'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/monthly-yearly'),
            icon: Icon(Icons.calendar_month_outlined,
                size: 18, color: scheme.primary),
            label: Text('Tổng kết', style: TextStyle(color: scheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: scheme.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng chi tiêu $monthLabel',
                            style: TextStyle(
                                color:
                                    scheme.onPrimary.withOpacity(0.75),
                                fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency(totalExpense),
                          style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: scheme.onPrimary.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: Icon(Icons.trending_down,
                          color: scheme.onPrimary, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Tỷ lệ sử dụng theo Hũ',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800)),
              const SizedBox(height: 16),
              if (jars.isEmpty)
                Text(
                  'Chưa có dữ liệu cho tháng này.',
                  style: TextStyle(color: Colors.grey.shade500),
                )
              else
                Column(
                  children: jars.map((e) {
                    final jar = e as Map<String, dynamic>;
                    final name = jar['name'] as String? ?? '';
                    final spent = (jar['spent'] ?? 0).toDouble();
                    final budget = (jar['budget'] ?? 0).toDouble();
                    final color = Colors.orange.shade400;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildJarProgressCard(
                        name,
                        spent,
                        budget,
                        color,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJarProgressCard(
      String title, double spent, double total, Color color) {
    final double percentage = total > 0 ? spent / total : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade100,
                color: color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã dùng: ${formatCurrency(spent)}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
              Text('Định mức: ${formatCurrency(total)}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
