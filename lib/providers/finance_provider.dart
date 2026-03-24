// lib/providers/finance_provider.dart
import 'package:flutter/material.dart';
import 'package:financial_management/models/account_model.dart';
import 'package:financial_management/models/category_model.dart';
import 'package:financial_management/models/goal_model.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/services/firebase_firestore_service.dart';
import 'dart:async';

class FinanceProvider extends ChangeNotifier {
  String? _uid;
  StreamSubscription? _txSub, _catSub, _accSub, _goalSub;

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<AccountModel> _accounts = [];
  List<GoalModel> _goals = [];

  bool _isLoading = false;
  String? _error;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // ── Getters ───────────────────────────────────────────────────────────
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<AccountModel> get accounts => _accounts;
  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.isIncome).toList();
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.isExpense).toList();

  double get totalBalance =>
      _accounts.fold(0, (sum, a) => sum + a.balance);

  List<TransactionModel> get currentMonthTransactions {
    return _transactions.where((tx) {
      return tx.date.year == _selectedMonth.year &&
          tx.date.month == _selectedMonth.month;
    }).toList();
  }

  double get monthlyIncome => currentMonthTransactions
      .where((t) => t.isIncome)
      .fold(0, (s, t) => s + t.amount);

  double get monthlyExpense => currentMonthTransactions
      .where((t) => t.isExpense)
      .fold(0, (s, t) => s + t.amount);

  double get monthlySaving => monthlyIncome - monthlyExpense;

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  // ── Auth change callback ──────────────────────────────────────────────
  void onAuthChanged(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _cancelStreams();
    if (uid != null) {
      _subscribeAll(uid);
    } else {
      _reset();
    }
  }

  void _subscribeAll(String uid) {
    _txSub = FirestoreService.transactionsStream(uid).listen((data) {
      _transactions = data;
      notifyListeners();
    });
    _catSub = FirestoreService.categoriesStream(uid).listen((data) {
      _categories = data;
      notifyListeners();
    });
    _accSub = FirestoreService.accountsStream(uid).listen((data) {
      _accounts = data;
      notifyListeners();
    });
    _goalSub = FirestoreService.goalsStream(uid).listen((data) {
      _goals = data;
      notifyListeners();
    });
  }

  void _cancelStreams() {
    _txSub?.cancel();
    _catSub?.cancel();
    _accSub?.cancel();
    _goalSub?.cancel();
  }

  void _reset() {
    _transactions = [];
    _categories = [];
    _accounts = [];
    _goals = [];
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> createTransaction({
    required double amount,
    required String type,
    required CategoryModel category,
    AccountModel? account,
    String? note,
    DateTime? date,
  }) async {
    if (_uid == null) return false;
    _setLoading(true);
    try {
      await FirestoreService.createTransaction(_uid!, {
        'amount': amount,
        'type': type,
        'categoryId': category.id,
        'categoryName': category.name,
        'categoryIcon': category.icon,
        'categoryColor': category.color,
        if (account != null) 'accountId': account.id,
        if (account != null) 'accountName': account.name,
        if (note != null && note.isNotEmpty) 'note': note,
        'date': date ?? DateTime.now(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(TransactionModel tx) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.deleteTransaction(
        _uid!, tx.id,
        amount: tx.amount,
        type: tx.type,
        accountId: tx.accountId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.createCategory(_uid!, {
        'name': name,
        'type': type,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(
      String catId, String name, String? icon, String? color) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.updateCategory(_uid!, catId, {
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String catId) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.deleteCategory(_uid!, catId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ACCOUNTS
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> createAccount({
    required String name,
    double balance = 0,
    double? allocationPercent,
    bool isGoalActive = false,
    double? targetAmount,
  }) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.createAccount(_uid!, {
        'name': name,
        'balance': balance,
        if (allocationPercent != null) 'allocationPercent': allocationPercent,
        'isGoalActive': isGoalActive,
        if (targetAmount != null) 'targetAmount': targetAmount,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(AccountModel acc, {
    String? name,
    double? allocationPercent,
    bool? isGoalActive,
    double? targetAmount,
  }) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.updateAccount(_uid!, acc.id, {
        'name': name ?? acc.name,
        'allocationPercent': allocationPercent ?? acc.allocationPercent,
        'isGoalActive': isGoalActive ?? acc.isGoalActive,
        if ((isGoalActive ?? acc.isGoalActive) && targetAmount != null)
          'targetAmount': targetAmount,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String accId) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.deleteAccount(_uid!, accId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GOALS
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> createGoal({
    required String title,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? deadline,
    String? icon,
    String? color,
    String? note,
  }) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.createGoal(_uid!, {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        if (deadline != null) 'deadline': deadline,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (note != null) 'note': note,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> contributeToGoal(String goalId, double amount) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.contributeToGoal(_uid!, goalId, amount);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoal(String goalId, Map<String, dynamic> data) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.updateGoal(_uid!, goalId, data);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    if (_uid == null) return false;
    try {
      await FirestoreService.deleteGoal(_uid!, goalId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STATISTICS HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    if (_uid == null) return {};
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    return FirestoreService.getSummary(_uid!, from, to);
  }

  Future<Map<String, double>> getExpenseByCategory(
      int year, int month) async {
    if (_uid == null) return {};
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    return FirestoreService.getExpenseByCategory(_uid!, from, to);
  }

  Future<Map<String, double>> getIncomeByCategory(
      int year, int month) async {
    if (_uid == null) return {};
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    return FirestoreService.getIncomeByCategory(_uid!, from, to);
  }

  Future<List<Map<String, dynamic>>> getYearlyData(int year) async {
    if (_uid == null) return [];
    return FirestoreService.getMonthlyData(_uid!, year);
  }

  Future<Map<DateTime, List<TransactionModel>>> getCalendarData(
      int year, int month) async {
    if (_uid == null) return {};
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    return FirestoreService.getTransactionsByDate(_uid!, from, to);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelStreams();
    super.dispose();
  }
}
