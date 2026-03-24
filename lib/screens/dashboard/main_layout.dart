// lib/screens/dashboard/main_layout.dart
import 'package:flutter/material.dart';
import 'package:financial_management/screens/dashboard/home_dashboard_screen.dart';
import 'package:financial_management/screens/transaction/transaction_list_screen.dart';
import 'package:financial_management/screens/report/statistics_report_screen.dart';
import 'package:financial_management/screens/goal/financial_goals_screen.dart';
import 'package:financial_management/screens/settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final _pages = const [
    HomeDashboardScreen(),
    TransactionListScreen(),
    StatisticsReportScreen(),
    FinancialGoalsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: scheme.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Giao dịch'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Báo cáo'),
          NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag_rounded),
              label: 'Mục tiêu'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: _currentIndex <= 1
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-transaction'),
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}
