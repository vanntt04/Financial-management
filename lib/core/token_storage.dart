import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyAccessToken  = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUser         = 'user_info';

  // ── Lưu tokens ───────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken,  accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ── Lưu user info ─────────────────────────────────────────
  static Future<void> saveUserInfo(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      final json = user is Map ? user : user.toJson();
      await prefs.setString(_keyUser, jsonEncode(json));
    }
  }

  // ── Lấy access token ──────────────────────────────────────
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  // ── Lấy refresh token ─────────────────────────────────────
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // ── Lấy user info ─────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Kiểm tra đã đăng nhập chưa ───────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Xóa tất cả (logout) ──────────────────────────────────
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUser);
  }
}
