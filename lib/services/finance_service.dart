import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/category_model.dart';

class FinanceService {
  /// Lấy tất cả danh mục của user hiện tại.
  static Future<List<CategoryModel>> getCategories({String? type}) async {
    final params = type != null ? {'type': type} : null;
    final body = await ApiClient.get(
      ApiConstants.categories,
      queryParams: params,
      withAuth: true,
    );
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Lấy danh mục theo loại.
  static Future<List<CategoryModel>> getCategoriesByType(String type) async {
    return getCategories(type: type);
  }
}
