import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/category_model.dart';

class CategoryService {
  /// Lấy danh sách danh mục, có thể lọc theo [type] ('INCOME' | 'EXPENSE').
  static Future<List<CategoryModel>> getCategories({String? type}) async {
    final url = type != null
        ? '${ApiConstants.categories}?type=$type'
        : ApiConstants.categories;
    final body = await ApiClient.get(url);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Tạo danh mục mới.
  static Future<CategoryModel> createCategory({
    required String categoryName,
    required String categoryType,
  }) async {
    final body = await ApiClient.post(
      ApiConstants.categories,
      {
        'categoryName': categoryName,
        'categoryType': categoryType,
      },
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  /// Cập nhật tên danh mục.
  static Future<CategoryModel> updateCategory(
    int id, {
    required String categoryName,
  }) async {
    final body = await ApiClient.put(
      '${ApiConstants.categories}/$id',
      {'categoryName': categoryName},
    );
    final data = body['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  /// Xóa danh mục.
  static Future<void> deleteCategory(int id) async {
    await ApiClient.delete('${ApiConstants.categories}/$id');
  }
}
