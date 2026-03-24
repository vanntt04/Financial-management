import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';

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

  /// Lấy tổng quan báo cáo tháng (tổng chi, tổng thu, theo từng hũ).
  /// Backend Spring Boot gợi ý response:
  /// {
  ///   "month": 3,
  ///   "year": 2026,
  ///   "totalExpense": 4500000,
  ///   "totalIncome": 10000000,
  ///   "jars": [
  ///     {"name": "Chi tiêu thiết yếu", "spent": 4000000, "budget": 7500000},
  ///     ...
  ///   ]
  /// }
  static Future<Map<String, dynamic>> getMonthlyReportSummary({
    required int month,
    required int year,
  }) async {
    final url =
        '${ApiConstants.monthlyReportSummary}?month=$month&year=$year';
    final body = await ApiClient.get(url);
    return body['data'] as Map<String, dynamic>? ?? body;
  }

  /// Lấy dữ liệu lịch giao dịch trong tháng.
  /// Gợi ý response:
  /// {
  ///   "month": 3,
  ///   "year": 2026,
  ///   "days": [
  ///     {"day": 5, "hasTransaction": true, "totalIncome": 0, "totalExpense": 150000},
  ///     ...
  ///   ]
  /// }
  static Future<List<Map<String, dynamic>>> getCalendarReport({
    required int month,
    required int year,
  }) async {
    final url = '${ApiConstants.calendarReport}?month=$month&year=$year';
    final body = await ApiClient.get(url);
    final data = body['data'];
    if (data is Map && data['days'] is List) {
      return (data['days'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  /// Ví dụ: lấy danh sách giao dịch theo ngày (dùng cho DailyDetailTransactionScreen).
  static Future<List<TransactionModel>> getTransactionsByDate(
      DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final url = '${ApiConstants.baseUrl}/api/transactions?date=$dateStr';
    final body = await ApiClient.get(url);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
