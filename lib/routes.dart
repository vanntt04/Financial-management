import 'package:flutter/material.dart';

// 1. Nhóm Dashboard
import 'screens/dashboard/main_layout.dart';
import 'screens/dashboard/home_dashboard_screen.dart';

// 2. Nhóm Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forget_password_screen.dart';
import 'screens/auth/change_password_screen.dart';

// 3. Nhóm Profile
import 'screens/profile/user_profile_screen.dart';
import 'screens/profile/add_edit_profile_screen.dart';

// 4. Nhóm Transaction
import 'screens/transaction/add_transaction_screen.dart';
import 'screens/transaction/transaction_list_screen.dart';
import 'screens/transaction/transaction_detail_screen.dart';
import 'screens/transaction/daily_detail_transaction_screen.dart';

// 5. Nhóm Report & Calendar
import 'screens/report/statistics_report_screen.dart';
import 'screens/report/calendar_view_screen.dart';
import 'screens/report/monthly_yearly_summary_screen.dart';

// 6. Nhóm Goals & Category
import 'screens/goal/financial_goals_screen.dart';
import 'screens/goal/goal_progress_screen.dart';
import 'screens/category/category_screen.dart';

// 7. Nhóm Settings
import 'screens/settings/settings_screen.dart';
import 'screens/settings/about_help_screen.dart';

class AppRoutes {
  // Định nghĩa các hằng số route
  static const String mainLayout = '/';
  static const String home = '/home';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';
  static const String changePassword = '/change-password';

  static const String profile = '/profile';
  static const String addEditProfile = '/add-edit-profile';

  static const String addTransaction = '/add-transaction';
  static const String transactionList = '/transaction-list';
  static const String transactionDetail = '/transaction-detail';
  static const String dailyDetail = '/daily-detail';

  static const String statisticsReports = '/statistics-reports';
  static const String calendarView = '/calendar-view';
  static const String monthlyYearly = '/monthly-yearly';

  static const String category = '/category';
  static const String financialGoals = '/financial-goals';
  static const String goalProgress = '/goal-progress';

  static const String settings = '/settings';
  static const String aboutHelp = '/about-help';

  static Map<String, WidgetBuilder> define() {
    return {
      mainLayout: (context) => const MainLayout(),
      home: (context) => const HomeDashboardScreen(),

      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgetPassword: (context) => const ForgetPasswordScreen(),
      changePassword: (context) => const ChangePasswordScreen(),

      profile: (context) => const UserProfileScreen(),
      addEditProfile: (context) => const AddEditProfileScreen(),

      addTransaction: (context) => const AddTransactionScreen(),
      transactionList: (context) => const TransactionListScreen(),
      transactionDetail: (context) => const TransactionDetailScreen(),
      dailyDetail: (context) => const DailyDetailTransactionScreen(),

      statisticsReports: (context) => const StatisticsReportScreen(),
      calendarView: (context) => const CalendarViewScreen(),
      monthlyYearly: (context) => const MonthlyYearlySummaryScreen(),

      category: (context) => const CategoryScreen(),
      financialGoals: (context) => const FinancialGoalsScreen(),
      goalProgress: (context) => const GoalProgressScreen(),

      settings: (context) => const SettingsScreen(),
      aboutHelp: (context) => const AboutHelpScreen(),
    };
  }
}