import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/financial_goal.dart';

class GoalService {
  /// Lấy danh sách tất cả mục tiêu tài chính.
  static Future<List<FinancialGoal>> getGoals() async {
    final body = await ApiClient.get(ApiConstants.goals);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => FinancialGoal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Tạo mục tiêu tài chính mới.
  static Future<FinancialGoal> createGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    String? deadline,
    String? icon,
  }) async {
    final body = await ApiClient.post(
      ApiConstants.goals,
      {
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline,
        'icon': icon,
      },
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return FinancialGoal.fromJson(data);
  }

  /// Cập nhật mục tiêu tài chính.
  static Future<FinancialGoal> updateGoal(
    int id,
    Map<String, dynamic> updateData,
  ) async {
    final body = await ApiClient.put(
      '${ApiConstants.goals}/$id',
      updateData,
    );
    final data = body['data'] as Map<String, dynamic>;
    return FinancialGoal.fromJson(data);
  }

  /// Xóa mục tiêu tài chính.
  static Future<void> deleteGoal(int id) async {
    await ApiClient.delete('${ApiConstants.goals}/$id');
  }

  /// Đóng góp vào mục tiêu (ví dụ: chuyển tiền từ một hũ vào hũ tiết kiệm của mục tiêu này).
  /// Backend có thể cần endpoint riêng.
  static Future<FinancialGoal> addSaving(int goalId, double amount) async {
    final body = await ApiClient.post(
      '${ApiConstants.goals}/$goalId/add-saving',
      {'amount': amount},
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return FinancialGoal.fromJson(data);
  }
}
