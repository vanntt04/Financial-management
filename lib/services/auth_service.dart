import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../core/token_storage.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  /// Đăng ký tài khoản mới — server gửi OTP về email.
  static Future<String> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final body = await ApiClient.post(ApiConstants.register, {
      'fullName':        fullName,
      'email':           email,
      'password':        password,
      'confirmPassword': confirmPassword,
    });
    return body['message'] as String? ?? 'Đăng ký thành công';
  }

  /// Đăng nhập — lưu token + user, trả về AuthResponseModel.
  static Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final body = await ApiClient.post(ApiConstants.login, {
      'email':    email,
      'password': password,
    });
    // Backend trả về: { success, message, data: { accessToken, refreshToken, user } }
    final data = body['data'] as Map<String, dynamic>;
    final auth = AuthResponseModel.fromJson(data);
    await TokenStorage.saveTokens(
      accessToken:  auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await TokenStorage.saveUserInfo(auth.user);
    return auth;
  }

  /// Xác thực OTP sau đăng ký.
  static Future<UserModel> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final body = await ApiClient.post(ApiConstants.verifyOtp, {
      'email':   email,
      'otpCode': otpCode,
    });
    final data = body['data'] as Map<String, dynamic>;
    final auth = AuthResponseModel.fromJson(data);
    await TokenStorage.saveTokens(
      accessToken:  auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await TokenStorage.saveUserInfo(auth.user);
    return auth.user;
  }

  /// Gửi lại OTP.
  static Future<String> resendOtp({required String email}) async {
    final body = await ApiClient.post(
        ApiConstants.resendOtp, {'email': email});
    return body['message'] as String? ?? 'Đã gửi lại OTP';
  }

  /// Quên mật khẩu — gửi OTP reset.
  static Future<String> forgotPassword({required String email}) async {
    final body = await ApiClient.post(
        ApiConstants.forgotPassword, {'email': email});
    return body['message'] as String? ?? 'Đã gửi OTP đặt lại mật khẩu';
  }

  /// Đặt lại mật khẩu với OTP.
  static Future<String> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = await ApiClient.post(ApiConstants.resetPassword, {
      'email':           email,
      'otpCode':         otpCode,
      'newPassword':     newPassword,
      'confirmPassword': confirmPassword,
    });
    return body['message'] as String? ?? 'Đặt lại mật khẩu thành công';
  }

  /// Đăng xuất — xóa token local.
  static Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await ApiClient.post(
          ApiConstants.logout,
          {'refreshToken': refreshToken},
          withAuth: true,
        );
      }
    } catch (_) {
      // Bỏ qua lỗi network khi logout
    } finally {
      await TokenStorage.clearTokens();
    }
  }
}
