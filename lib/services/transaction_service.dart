import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/transaction.dart';

class TransactionService {
  /// Lấy danh sách giao dịch. 
  /// Có thể lọc theo [startDate], [endDate], [jarId], [categoryId].
  static Future<List<TransactionModel>> getTransactions({
    String? startDate,
    String? endDate,
    int? jarId,
    int? categoryId,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (jarId != null) queryParams['jarId'] = jarId.toString();
    if (categoryId != null) queryParams['categoryId'] = categoryId.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    final url = queryString.isNotEmpty 
        ? '${ApiConstants.transactions}?$queryString' 
        : ApiConstants.transactions;

    final body = await ApiClient.get(url);
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Tạo một giao dịch mới (Thu hoặc Chi).
  /// [amount]: Số tiền.
  /// [type]: 'INCOME' hoặc 'EXPENSE'.
  /// [jarId]: ID của hũ tài chính liên quan.
  /// [categoryId]: ID của danh mục.
  static Future<TransactionModel> createTransaction({
    required double amount,
    required String type,
    required int jarId,
    required int categoryId,
    String? note,
    String? date,
  }) async {
    final body = await ApiClient.post(
      ApiConstants.transactions,
      {
        'amount': amount,
        'type': type,
        'jarId': jarId,
        'categoryId': categoryId,
        'note': note,
        'transactionDate': date ?? DateTime.now().toIso8601String(),
      },
      withAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  /// Cập nhật giao dịch.
  static Future<TransactionModel> updateTransaction(
    int id,
    Map<String, dynamic> updateData,
  ) async {
    final body = await ApiClient.put(
      '${ApiConstants.transactions}/$id',
      updateData,
    );
    final data = body['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  /// Xóa giao dịch.
  static Future<void> deleteTransaction(int id) async {
    await ApiClient.delete('${ApiConstants.transactions}/$id');
  }

  /// Lấy chi tiết một giao dịch.
  static Future<TransactionModel> getTransactionById(int id) async {
    final body = await ApiClient.get('${ApiConstants.transactions}/$id');
    final data = body['data'] as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }
}
