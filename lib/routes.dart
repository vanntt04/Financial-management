// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/providers/auth_provider.dart';
import 'package:financial_management/screens/splash_screen.dart';
import 'package:financial_management/screens/auth/login_screen.dart';
import 'package:financial_management/screens/auth/register_screen.dart';
import 'package:financial_management/screens/auth/forget_password_screen.dart';
import 'package:financial_management/screens/auth/change_password_screen.dart';
import 'package:financial_management/screens/dashboard/main_layout.dart';
import 'package:financial_management/screens/dashboard/home_dashboard_screen.dart';
import 'package:financial_management/screens/transaction/add_transaction_screen.dart';
import 'package:financial_management/screens/transaction/transaction_list_screen.dart';
import 'package:financial_management/screens/transaction/transaction_detail_screen.dart';
import 'package:financial_management/screens/transaction/daily_detail_transaction_screen.dart';
import 'package:financial_management/screens/category/category_screen.dart';
import 'package:financial_management/screens/goal/financial_goals_screen.dart';
import 'package:financial_management/screens/goal/goal_progress_screen.dart';
import 'package:financial_management/screens/profile/user_profile_screen.dart';
import 'package:financial_management/screens/profile/add_edit_profile_screen.dart';
import 'package:financial_management/screens/report/statistics_report_screen.dart';
import 'package:financial_management/screens/report/calendar_view_screen.dart';
import 'package:financial_management/screens/report/monthly_yearly_summary_screen.dart';
import 'package:financial_management/screens/settings/settings_screen.dart';
import 'package:financial_management/screens/settings/about_help_screen.dart';
import 'package:financial_management/screens/account/add_edit_account_screen.dart';

class AppRoutes {
  static const String splash         = '/';
  static const String mainLayout     = '/main';
  static const String home           = '/home';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String forgetPassword = '/forget-password';
  static const String changePassword = '/change-password';
  static const String profile        = '/profile';
  static const String addEditProfile = '/add-edit-profile';
  static const String addTransaction    = '/add-transaction';
  static const String transactionList   = '/transaction-list';
  static const String transactionDetail = '/transaction-detail';
  static const String dailyDetail       = '/daily-detail';
  static const String statisticsReports = '/statistics-reports';
  static const String calendarView      = '/calendar-view';
  static const String monthlyYearly     = '/monthly-yearly';
  static const String category          = '/category';
  static const String financialGoals    = '/financial-goals';
  static const String goalProgress      = '/goal-progress';
  static const String settings          = '/settings';
  static const String aboutHelp         = '/about-help';
  static const String addEditAccount    = '/add-edit-account';

  static Map<String, WidgetBuilder> define() => {
    splash:         (_) => const SplashScreen(),
    mainLayout:     (_) => const MainLayout(),
    home:           (_) => const HomeDashboardScreen(),
    login:          (_) => const LoginScreen(),
    register:       (_) => const RegisterScreen(),
    forgetPassword: (_) => const ForgetPasswordScreen(),
    changePassword: (_) => const ChangePasswordScreen(),
    profile:        (_) => const UserProfileScreen(),
    addEditProfile: (_) => const AddEditProfileScreen(),
    addTransaction:    (_) => const AddTransactionScreen(),
    transactionList:   (_) => const TransactionListScreen(),
    transactionDetail: (_) => const TransactionDetailScreen(),
    dailyDetail:       (_) => const DailyDetailTransactionScreen(),
    statisticsReports: (_) => const StatisticsReportScreen(),
    calendarView:      (_) => const CalendarViewScreen(),
    monthlyYearly:     (_) => const MonthlyYearlySummaryScreen(),
    category:          (_) => const CategoryScreen(),
    financialGoals:    (_) => const FinancialGoalsScreen(),
    goalProgress:      (_) => const GoalProgressScreen(),
    settings:          (_) => const SettingsScreen(),
    aboutHelp:         (_) => const AboutHelpScreen(),
    addEditAccount:    (_) => const AddEditAccountScreen(),
  };
}

