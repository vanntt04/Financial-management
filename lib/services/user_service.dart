import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';

class UserService {
  /// Lấy thông tin user hiện tại từ local storage.
  static Future<UserModel?> getCurrentUser() async {
    final info = await TokenStorage.getUserInfo();
    if (info == null) return null;
    return UserModel.fromJson(info);
  }
}
