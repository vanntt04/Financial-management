import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../core/token_storage.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  /// Đăng ký tài khoản mới. Server sẽ gửi OTP về email.
  static Future<String> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final body = await ApiClient.post(ApiConstants.register, {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return body['message'] as String? ?? 'Đăng ký thành công';
  }

  /// Đăng nhập, lưu token + user info, trả về AuthResponseModel.
  static Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final body = await ApiClient.post(ApiConstants.login, {
      'email': email,
      'password': password,
    });
    final auth = AuthResponseModel.fromJson(body);
    await TokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await TokenStorage.saveUserInfo(auth.user);
    return auth;
  }

  /// Xác thực OTP sau khi đăng ký. Lưu token + user info, trả về UserModel.
  static Future<UserModel> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final body = await ApiClient.post(ApiConstants.verifyOtp, {
      'email': email,
      'otpCode': otpCode,
    });
    final data = body['data'] as Map<String, dynamic>;
    final auth = AuthResponseModel.fromJson(data);
    await TokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await TokenStorage.saveUserInfo(auth.user);
    return auth.user;
  }

  /// Gửi lại OTP.
  static Future<String> resendOtp({required String email}) async {
    final body = await ApiClient.post(ApiConstants.resendOtp, {'email': email});
    return body['message'] as String? ?? 'Đã gửi lại OTP';
  }

  /// Yêu cầu đặt lại mật khẩu (gửi email chứa link/token).
  static Future<String> forgotPassword({required String email}) async {
    final body =
        await ApiClient.post(ApiConstants.forgotPassword, {'email': email});
    return body['message'] as String? ??
        'Nếu email tồn tại, hướng dẫn đặt lại mật khẩu sẽ được gửi.';
  }

  /// Đặt lại mật khẩu bằng token (ví dụ từ email).
  static Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = await ApiClient.post(ApiConstants.resetPassword, {
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    return body['message'] as String? ?? 'Đặt lại mật khẩu thành công';
  }

  /// Đăng xuất và xóa token.
  static Future<void> logout() async {
    try {
      await ApiClient.post(ApiConstants.logout, {}, withAuth: true);
    } finally {
      await TokenStorage.clearTokens();
    }
  }
}
