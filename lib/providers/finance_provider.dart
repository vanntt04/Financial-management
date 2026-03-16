// lib/providers/finance_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinanceProvider extends ChangeNotifier {
  final _api = ApiService();

  // ── State ─────────────────────────────────────────────────
  ApiDashboard? _dashboard;
  List<ApiTransaction> _transactions = [];
  List<ApiCategory> _categories = [];
  List<ApiAccount> _accounts = [];

  bool _isDashboardLoading = false;
  bool _isTransactionsLoading = false;
  String? _dashboardError;
  String? _transactionsError;
  String _transactionFilter = 'ALL';

  // ── Getters ───────────────────────────────────────────────
  ApiDashboard? get dashboard => _dashboard;
  List<ApiTransaction> get transactions => _transactions;
  List<ApiCategory> get categories => _categories;
  List<ApiAccount> get accounts => _accounts;
  bool get isDashboardLoading => _isDashboardLoading;
  bool get isTransactionsLoading => _isTransactionsLoading;
  String? get dashboardError => _dashboardError;
  String? get transactionsError => _transactionsError;
  String get transactionFilter => _transactionFilter;

  // ── Load Dashboard ────────────────────────────────────────
  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _dashboardError = null;
    notifyListeners();
    try {
      _dashboard = await _api.getDashboard();
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  // ── Load Transactions ─────────────────────────────────────
  Future<void> loadTransactions({String type = 'ALL'}) async {
    _transactionFilter = type;
    _isTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();
    try {
      _transactions = await _api.getTransactions(type: type);
    } catch (e) {
      _transactionsError = e.toString();
    } finally {
      _isTransactionsLoading = false;
      notifyListeners();
    }
  }

  // ── Load Categories ───────────────────────────────────────
  Future<void> loadCategories({String? type}) async {
    try {
      _categories = await _api.getCategories(type: type);
      notifyListeners();
    } catch (_) {}
  }

  // ── Load Accounts ─────────────────────────────────────────
  Future<void> loadAccounts() async {
    try {
      _accounts = await _api.getAccounts();
      notifyListeners();
    } catch (_) {}
  }

  // ── Transaction CRUD ──────────────────────────────────────
  Future<bool> createTransaction({
    required double amount,
    required int accountId,
    required int categoryId,
    required String transactionType,
    DateTime? transactionDate,
  }) async {
    try {
      await _api.createTransaction(
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        transactionType: transactionType,
        transactionDate: transactionDate,
      );
      await Future.wait([
        loadDashboard(),
        loadTransactions(type: _transactionFilter),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTransaction(int transactionId) async {
    try {
      await _api.deleteTransaction(transactionId);
      await Future.wait([
        loadDashboard(),
        loadTransactions(type: _transactionFilter),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Account CRUD ──────────────────────────────────────────
  Future<bool> createAccount({
    required String accountName,
    double? allocationPercentage,
    bool isGoalActive = false,
    double? targetAmount,
  }) async {
    try {
      await _api.createAccount(
        accountName: accountName,
        allocationPercentage: allocationPercentage,
        isGoalActive: isGoalActive,
        targetAmount: targetAmount,
      );
      await Future.wait([loadAccounts(), loadDashboard()]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAccount({
    required int accountId,
    required String accountName,
    double? allocationPercentage,
    bool isGoalActive = false,
    double? targetAmount,
  }) async {
    try {
      await _api.updateAccount(
        accountId: accountId,
        accountName: accountName,
        allocationPercentage: allocationPercentage,
        isGoalActive: isGoalActive,
        targetAmount: targetAmount,
      );
      await Future.wait([loadAccounts(), loadDashboard()]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount(int accountId) async {
    try {
      await _api.deleteAccount(accountId);
      await Future.wait([loadAccounts(), loadDashboard()]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Reset & Load All ──────────────────────────────────────
  void reset() {
    _dashboard = null;
    _transactions = [];
    _categories = [];
    _accounts = [];
    _dashboardError = null;
    _transactionsError = null;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadDashboard(),
      loadTransactions(),
      loadAccounts(),
    ]);
  }
}
