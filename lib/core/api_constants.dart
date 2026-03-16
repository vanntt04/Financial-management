import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  static String get register  => '$baseUrl/api/auth/register';
  static String get login     => '$baseUrl/api/auth/login';
  static String get verifyOtp => '$baseUrl/api/auth/verify-otp';
  static String get resendOtp => '$baseUrl/api/auth/resend-otp';
  static String get logout    => '$baseUrl/api/auth/logout';
  static String get categories => '$baseUrl/api/categories';
}
