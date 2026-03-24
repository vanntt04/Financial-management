import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/budget_model.dart';

class BudgetService {
  /// Lấy danh sách ngân sách (hạn mức chi tiêu).
  static Future<List<BudgetModel>> getBudgets() async {
    final body = await ApiClient.get(ApiConstants.budgets);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Tạo ngân sách mới cho một danh mục.
  static Future<BudgetModel> createBudget({
    required double limitAmount,
    required String period, // 'MONTHLY', 'WEEKLY', 'DAILY'
    required int categoryId,
    required String startDate,
    required String endDate,
  }) async {
    final body = await ApiClient.post(
      ApiConstants.budgets,
      {
        'limitAmount': limitAmount,
        'period': period,
        'categoryId': categoryId,
        'startDate': startDate,
        'endDate': endDate,
      },
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return BudgetModel.fromJson(data);
  }

  /// Cập nhật ngân sách.
  static Future<BudgetModel> updateBudget(
    int id,
    Map<String, dynamic> updateData,
  ) async {
    final body = await ApiClient.put(
      '${ApiConstants.budgets}/$id',
      updateData,
    );
    final data = body['data'] as Map<String, dynamic>;
    return BudgetModel.fromJson(data);
  }

  /// Xóa ngân sách.
  static Future<void> deleteBudget(int id) async {
    await ApiClient.delete('${ApiConstants.budgets}/$id');
  }
}
