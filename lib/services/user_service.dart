import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/user_model.dart';

class UserService {
  /// Lấy thông tin người dùng hiện tại (dựa trên access token).
  static Future<UserModel> getCurrentUser() async {
    final body =
        await ApiClient.get(ApiConstants.currentUser); // with auth header
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return UserModel.fromJson(data);
  }

  /// Cập nhật hồ sơ người dùng hiện tại.
  static Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    String? phone,
  }) async {
    final body = await ApiClient.put(ApiConstants.currentUser, {
      'fullName': fullName,
      'email': email,
      'phone': phone,
    });
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return UserModel.fromJson(data);
  }
  //update profile
}

