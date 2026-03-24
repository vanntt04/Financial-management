import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  // ── Auth ────────────────────────────────────────────────────────────────────
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get verifyOtp => '$baseUrl/api/auth/verify-otp';
  static String get resendOtp => '$baseUrl/api/auth/resend-otp';
  static String get logout => '$baseUrl/api/auth/logout';
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';
  static String get verifyForgotOtp => '$baseUrl/api/auth/verify-otp';
  static String get resetPassword => '$baseUrl/api/auth/reset-password';

  // ── User profile ───────────────────────────────────────────────────────────
  static String get currentUser => '$baseUrl/api/users/me';

  // ── Accounts / Jars ────────────────────────────────────────────────────────
  static String get accounts => '$baseUrl/api/accounts';

  // ── Transactions ───────────────────────────────────────────────────────────
  static String get transactions => '$baseUrl/api/transactions';

  // ── Financial Goals ────────────────────────────────────────────────────────
  static String get goals => '$baseUrl/api/goals';

  // ── Finance / categories / reports ─────────────────────────────────────────
  static String get categories => '$baseUrl/api/categories';
  static String get monthlyReportSummary =>
      '$baseUrl/api/reports/monthly-summary';
  static String get calendarReport => '$baseUrl/api/reports/calendar';
}
