import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class TokenStorage {
  static const _keyAccessToken  = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId       = 'user_id';
  static const _keyFullName     = 'user_full_name';
  static const _keyEmail        = 'user_email';

  // ── Tokens ────────────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── User info ─────────────────────────────────────────────────────────────

  static Future<void> saveUserInfo(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.userId);
    await prefs.setString(_keyFullName, user.fullName);
    await prefs.setString(_keyEmail, user.email);
  }

  static Future<UserModel?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId   = prefs.getInt(_keyUserId);
    final fullName = prefs.getString(_keyFullName);
    final email    = prefs.getString(_keyEmail);
    if (userId == null || fullName == null || email == null) return null;
    return UserModel(userId: userId, fullName: fullName, email: email);
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyEmail);
  }
}
