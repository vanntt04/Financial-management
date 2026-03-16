// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/token_storage.dart';

String get kBaseUrl {
  if (kIsWeb) return 'http://localhost:8080/api';
  return 'http://10.0.2.2:8080/api';
}

class ApiTransaction {
  final int transactionId;
  final double amount;
  final String transactionType;
  final String categoryName;
  final String? accountName;
  final int? categoryId;
  final int? accountId;
  final DateTime transactionDate;

  ApiTransaction({
    required this.transactionId,
    required this.amount,
    required this.transactionType,
    required this.categoryName,
    this.accountName,
    this.categoryId,
    this.accountId,
    required this.transactionDate,
  });

  bool get isIncome => transactionType == 'INCOME';
  bool get isExpense => transactionType == 'EXPENSE';

  factory ApiTransaction.fromJson(Map<String, dynamic> j) => ApiTransaction(
    transactionId: j['transactionId'] as int,
    amount: (j['amount'] as num).toDouble(),
    transactionType: j['transactionType'] as String,
    categoryName: j['categoryName'] ?? '',
    accountName: j['accountName'],
    categoryId: j['categoryId'],
    accountId: j['accountId'],
    transactionDate: DateTime.parse(j['transactionDate']),
  );
}

class ApiAccount {
  final int accountId;
  final String accountName;
  final double balance;
  final double? allocationPercentage;
  final bool isGoalActive;
  final double? targetAmount;

  ApiAccount({
    required this.accountId,
    required this.accountName,
    required this.balance,
    this.allocationPercentage,
    required this.isGoalActive,
    this.targetAmount,
  });

  factory ApiAccount.fromJson(Map<String, dynamic> j) => ApiAccount(
    accountId: j['accountId'] as int,
    accountName: j['accountName'] as String,
    balance: (j['balance'] as num).toDouble(),
    allocationPercentage: (j['allocationPercentage'] as num?)?.toDouble(),
    isGoalActive: j['isGoalActive'] as bool? ?? false,
    targetAmount: (j['targetAmount'] as num?)?.toDouble(),
  );
}

class ApiCategory {
  final int categoryId;
  final String categoryName;
  final String categoryType;

  ApiCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> j) => ApiCategory(
    categoryId: j['categoryId'] as int,
    categoryName: j['categoryName'] as String,
    categoryType: j['categoryType'] as String,
  );
}

class ApiDashboard {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySaving;
  final List<ApiAccount> accounts;
  final List<ApiTransaction> recentTransactions;

  ApiDashboard({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySaving,
    required this.accounts,
    required this.recentTransactions,
  });

  factory ApiDashboard.fromJson(Map<String, dynamic> j) => ApiDashboard(
    totalBalance: (j['totalBalance'] as num).toDouble(),
    monthlyIncome: (j['monthlyIncome'] as num).toDouble(),
    monthlyExpense: (j['monthlyExpense'] as num).toDouble(),
    monthlySaving: (j['monthlySaving'] as num).toDouble(),
    accounts:
    (j['accounts'] as List).map((e) => ApiAccount.fromJson(e)).toList(),
    recentTransactions: (j['recentTransactions'] as List)
        .map((e) => ApiTransaction.fromJson(e))
        .toList(),
  );
}

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiDashboard> getDashboard() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/dashboard'),
      headers: await _authHeaders(),
    );
    _check(res);
    return ApiDashboard.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes))['data']);
  }

  Future<List<ApiTransaction>> getTransactions({String type = 'ALL'}) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/transactions?type=$type'),
      headers: await _authHeaders(),
    );
    _check(res);
    final data = jsonDecode(utf8.decode(res.bodyBytes))['data'];
    return (data['transactions'] as List)
        .map((e) => ApiTransaction.fromJson(e))
        .toList();
  }

  Future<ApiTransaction> createTransaction({
    required double amount,
    required int accountId,
    required int categoryId,
    required String transactionType,
    DateTime? transactionDate,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/transactions'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'amount': amount,
        'accountId': accountId,
        'categoryId': categoryId,
        'transactionType': transactionType,
        'transactionDate':
        (transactionDate ?? DateTime.now()).toIso8601String(),
      }),
    );
    _check(res);
    return ApiTransaction.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes))['data']);
  }

  Future<void> deleteTransaction(int id) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/transactions/$id'),
      headers: await _authHeaders(),
    );
    _check(res);
  }

  Future<List<ApiCategory>> getCategories({String? type}) async {
    var url = '$kBaseUrl/categories';
    if (type != null) url += '?type=$type';
    final res = await http.get(Uri.parse(url), headers: await _authHeaders());
    _check(res);
    return (jsonDecode(utf8.decode(res.bodyBytes))['data'] as List)
        .map((e) => ApiCategory.fromJson(e))
        .toList();
  }

  Future<List<ApiAccount>> getAccounts() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/accounts'),
      headers: await _authHeaders(),
    );
    _check(res);
    return (jsonDecode(utf8.decode(res.bodyBytes))['data'] as List)
        .map((e) => ApiAccount.fromJson(e))
        .toList();
  }


  // ── Account CRUD ─────────────────────────────────────────

  Future<ApiAccount> createAccount({
    required String accountName,
    double? allocationPercentage,
    bool isGoalActive = false,
    double? targetAmount,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/accounts'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'accountName': accountName,
        if (allocationPercentage != null)
          'allocationPercentage': allocationPercentage,
        'isGoalActive': isGoalActive,
        if (targetAmount != null) 'targetAmount': targetAmount,
      }),
    );
    _check(res);
    return ApiAccount.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes))['data']);
  }

  Future<ApiAccount> updateAccount({
    required int accountId,
    required String accountName,
    double? allocationPercentage,
    bool isGoalActive = false,
    double? targetAmount,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/accounts/$accountId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'accountName': accountName,
        if (allocationPercentage != null)
          'allocationPercentage': allocationPercentage,
        'isGoalActive': isGoalActive,
        if (targetAmount != null) 'targetAmount': targetAmount,
      }),
    );
    _check(res);
    return ApiAccount.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes))['data']);
  }

  Future<void> deleteAccount(int accountId) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/accounts/$accountId'),
      headers: await _authHeaders(),
    );
    _check(res);
  }

  void _check(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(body['message'] ?? 'Lỗi server: ${res.statusCode}');
    }
  }}
