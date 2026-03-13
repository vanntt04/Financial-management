import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../utils/currency_formatter.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final myAccount = Account(
      id: 1,
      totalBalance: 20000000,
      jars: [
        Jar(id: 1, name: 'Chi tiêu thiết yếu', percentage: 0.5, currentAmount: 10000000, type: 'SPENDING'),
        Jar(id: 2, name: 'Tiết kiệm dài hạn', percentage: 0.3, currentAmount: 6000000, type: 'SAVING'),
        Jar(id: 3, name: 'Đầu tư & Giải trí', percentage: 0.2, currentAmount: 4000000, type: 'SPENDING'),
      ],
    );

    return Scaffold(
      backgroundColor: scheme.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Green header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(color: scheme.onPrimary.withOpacity(0.75), fontSize: 13),
                        ),
                        Text(
                          'Người dùng',
                          style: TextStyle(color: scheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.onPrimary.withOpacity(0.15),
                      child: Icon(Icons.person, color: scheme.onPrimary, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // ── White rounded content ──
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F7F4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance card
                      _buildBalanceCard(context, myAccount.totalBalance, scheme),
                      const SizedBox(height: 24),

                      // Quick actions
                      _buildQuickActions(context, scheme),
                      const SizedBox(height: 28),

                      // Jars
                      Text(
                        'Phân bổ quỹ (Hũ)',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 12),
                      ...myAccount.jars.map((jar) => _buildJarItem(context, jar, scheme)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng tài sản',
            style: TextStyle(color: scheme.onPrimary.withOpacity(0.75), fontSize: 13, letterSpacing: 0.3),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(balance),
            style: TextStyle(color: scheme.onPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: scheme.onPrimary.withOpacity(0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat(Icons.arrow_downward_rounded, 'Thu tháng này', 20000000, Colors.greenAccent.shade200, scheme.onPrimary),
              const SizedBox(width: 32),
              _buildMiniStat(Icons.arrow_upward_rounded, 'Chi tháng này', 4500000, Colors.redAccent.shade100, scheme.onPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, double amount, Color amountColor, Color labelColor) {
    return Row(
      children: [
        Icon(icon, color: amountColor, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: labelColor.withOpacity(0.65), fontSize: 11)),
            Text(
              formatCurrency(amount),
              style: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme scheme) {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Thêm', 'route': '/add-transaction'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Báo cáo', 'route': '/statistics-reports'},
      {'icon': Icons.flag_outlined, 'label': 'Mục tiêu', 'route': '/financial-goals'},
      {'icon': Icons.category_outlined, 'label': 'Danh mục', 'route': '/category'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, a['route'] as String),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(a['icon'] as IconData, color: scheme.primary, size: 26),
              ),
              const SizedBox(height: 6),
              Text(a['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJarItem(BuildContext context, Jar jar, ColorScheme scheme) {
    final isSaving = jar.type == 'SAVING';
    final color = isSaving ? const Color(0xFF009688) : scheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
            child: Icon(isSaving ? Icons.savings_outlined : Icons.account_balance_wallet_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jar.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: jar.percentage,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade100,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatCurrency(jar.currentAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text('${(jar.percentage * 100).toInt()}%', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
