// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:financial_management/services/firebase_auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _user?.uid;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get displayName =>
      _userData?['displayName'] ?? _user?.displayName ?? 'Người dùng';
  String? get photoURL => _userData?['photoURL'] ?? _user?.photoURL;
  String get email => _user?.email ?? '';
  String get currency => _userData?['currency'] ?? 'VND';

  AuthProvider() {
    FirebaseAuthService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      _status = AuthStatus.authenticated;
      await _loadUserData();
    } else {
      _status = AuthStatus.unauthenticated;
      _userData = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    _userData = await FirebaseAuthService.getUserData();
    notifyListeners();
  }

  // ── Register ─────────────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.register(
          fullName: fullName, email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.login(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await FirebaseAuthService.logout();
  }

  // ── Forgot Password ───────────────────────────────────────────────────
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.forgotPassword(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Change Password ───────────────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? currency,
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
        currency: currency,
        notificationsEnabled: notificationsEnabled,
        darkMode: darkMode,
      );
      await _loadUserData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _error = null;
    notifyListeners();
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}
