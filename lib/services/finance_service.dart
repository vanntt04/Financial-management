import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/category_model.dart';

class FinanceService {
  /// Lấy danh sách tất cả danh mục.
  static Future<List<CategoryModel>> getCategories() async {
    final body = await ApiClient.get(ApiConstants.categories);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Lấy danh mục theo loại ('INCOME' hoặc 'EXPENSE').
  static Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final all = await getCategories();
    return all.where((c) => c.categoryType == type).toList();
  }
}
