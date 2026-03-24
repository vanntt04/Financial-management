import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/account_model.dart';

class AccountService {
  /// Lấy danh sách tất cả hũ/tài khoản.
  static Future<List<AccountModel>> getAccounts() async {
    final body = await ApiClient.get(ApiConstants.accounts);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }





  /// Tạo hũ/tài khoản mới.
  static Future<AccountModel> createAccount({
    required String accountName,
    required double balance,
    required int currencyId,
    double? allocationPercentage,
    bool isGoalActive = false,
    double? targetAmount,
    String? targetDate,
  }) async {
    final body = await ApiClient.post(
      ApiConstants.accounts,
      {
        'name': accountName,
        'currentAmount': balance,
        'currencyId': currencyId,
        if (allocationPercentage != null) 'percentage': allocationPercentage,
        'isGoalActive': isGoalActive,
        if (targetAmount != null) 'targetAmount': targetAmount,
        if (targetDate != null) 'targetDate': targetDate,
      },
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return AccountModel.fromJson(data);
  }





  /// Cập nhật thông tin hũ/tài khoản.
  static Future<AccountModel> updateAccount(
    int id,
    Map<String, dynamic> data,
  ) async {
    final body = await ApiClient.put('${ApiConstants.accounts}/$id', data);
    final respData = body['data'] as Map<String, dynamic>;
    return AccountModel.fromJson(respData);
  }

  /// Xóa hũ/tài khoản (soft delete).
  static Future<void> deleteAccount(int id) async {
    await ApiClient.delete('${ApiConstants.accounts}/$id');
  }
}
