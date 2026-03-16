class ApiConstants {
  // ── Auth ──────────────────────────────────────────────────
  static const String register       = '/auth/register';
  static const String login          = '/auth/login';
  static const String verifyOtp      = '/auth/verify-otp';
  static const String resendOtp      = '/auth/resend-otp';
  static const String logout         = '/auth/logout';
  static const String refreshToken   = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword  = '/auth/reset-password';

  // ── Finance ───────────────────────────────────────────────
  static const String categories  = '/categories';
  static const String transactions = '/transactions';
  static const String accounts    = '/accounts';
  static const String dashboard   = '/dashboard';
}
