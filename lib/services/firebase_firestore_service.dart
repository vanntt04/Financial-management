// lib/services/firebase_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_management/models/transaction_model.dart';
import 'package:financial_management/models/category_model.dart';
import 'package:financial_management/models/account_model.dart';
import 'package:financial_management/models/goal_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Helpers ──────────────────────────────────────────────────────────
  static CollectionReference _col(String uid, String sub) =>
      _db.collection('users').doc(uid).collection(sub);

  // ═══════════════════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  static Stream<List<TransactionModel>> transactionsStream(String uid) {
    return _col(uid, 'transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                TransactionModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  static Future<List<TransactionModel>> getTransactions(String uid,
      {String? type, DateTime? from, DateTime? to}) async {
    Query q = _col(uid, 'transactions').orderBy('date', descending: true);
    if (type != null && type != 'ALL') q = q.where('type', isEqualTo: type);
    if (from != null) q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    if (to != null) q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    final snap = await q.get();
    return snap.docs
        .map((d) => TransactionModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<TransactionModel> createTransaction(
      String uid, Map<String, dynamic> data) async {
    final ref = await _col(uid, 'transactions').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Update account balance
    if (data['accountId'] != null) {
      final amount = (data['amount'] as num).toDouble();
      final delta = data['type'] == 'INCOME' ? amount : -amount;
      await _col(uid, 'accounts').doc(data['accountId']).update({
        'balance': FieldValue.increment(delta),
      });
    }
    final doc = await ref.get();
    return TransactionModel.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<void> updateTransaction(
      String uid, String txId, Map<String, dynamic> data,
      {double? oldAmount, String? oldType, String? oldAccountId}) async {
    // Reverse old balance impact
    if (oldAccountId != null && oldAmount != null && oldType != null) {
      final oldDelta = oldType == 'INCOME' ? -oldAmount : oldAmount;
      await _col(uid, 'accounts').doc(oldAccountId).update({
        'balance': FieldValue.increment(oldDelta),
      });
    }
    await _col(uid, 'transactions').doc(txId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Apply new balance impact
    if (data['accountId'] != null) {
      final amount = (data['amount'] as num).toDouble();
      final delta = data['type'] == 'INCOME' ? amount : -amount;
      await _col(uid, 'accounts').doc(data['accountId']).update({
        'balance': FieldValue.increment(delta),
      });
    }
  }

  static Future<void> deleteTransaction(
      String uid, String txId,
      {double? amount, String? type, String? accountId}) async {
    await _col(uid, 'transactions').doc(txId).delete();
    // Reverse balance
    if (accountId != null && amount != null && type != null) {
      final delta = type == 'INCOME' ? -amount : amount;
      await _col(uid, 'accounts').doc(accountId).update({
        'balance': FieldValue.increment(delta),
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════

  static Stream<List<CategoryModel>> categoriesStream(String uid) {
    return _col(uid, 'categories')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                CategoryModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  static Future<List<CategoryModel>> getCategories(String uid,
      {String? type}) async {
    Query q = _col(uid, 'categories').orderBy('createdAt');
    if (type != null) q = q.where('type', isEqualTo: type);
    final snap = await q.get();
    return snap.docs
        .map((d) =>
            CategoryModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<CategoryModel> createCategory(
      String uid, Map<String, dynamic> data) async {
    final ref = await _col(uid, 'categories').add({
      ...data,
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return CategoryModel.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<void> updateCategory(
      String uid, String catId, Map<String, dynamic> data) async {
    await _col(uid, 'categories').doc(catId).update(data);
  }

  static Future<void> deleteCategory(String uid, String catId) async {
    await _col(uid, 'categories').doc(catId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ACCOUNTS (Jars)
  // ═══════════════════════════════════════════════════════════════════════

  static Stream<List<AccountModel>> accountsStream(String uid) {
    return _col(uid, 'accounts')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                AccountModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  static Future<List<AccountModel>> getAccounts(String uid) async {
    final snap = await _col(uid, 'accounts')
        .orderBy('createdAt')
        .get();
    return snap.docs
        .map((d) =>
            AccountModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<AccountModel> createAccount(
      String uid, Map<String, dynamic> data) async {
    final ref = await _col(uid, 'accounts').add({
      ...data,
      'balance': data['balance'] ?? 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return AccountModel.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<void> updateAccount(
      String uid, String accId, Map<String, dynamic> data) async {
    await _col(uid, 'accounts').doc(accId).update(data);
  }

  static Future<void> deleteAccount(String uid, String accId) async {
    await _col(uid, 'accounts').doc(accId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FINANCIAL GOALS
  // ═══════════════════════════════════════════════════════════════════════

  static Stream<List<GoalModel>> goalsStream(String uid) {
    return _col(uid, 'goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                GoalModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  static Future<List<GoalModel>> getGoals(String uid) async {
    final snap = await _col(uid, 'goals')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) =>
            GoalModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  static Future<GoalModel> createGoal(
      String uid, Map<String, dynamic> data) async {
    final ref = await _col(uid, 'goals').add({
      ...data,
      'currentAmount': data['currentAmount'] ?? 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return GoalModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<void> updateGoal(
      String uid, String goalId, Map<String, dynamic> data) async {
    await _col(uid, 'goals').doc(goalId).update(data);
  }

  static Future<void> contributeToGoal(
      String uid, String goalId, double amount) async {
    await _col(uid, 'goals').doc(goalId).update({
      'currentAmount': FieldValue.increment(amount),
    });
  }

  static Future<void> deleteGoal(String uid, String goalId) async {
    await _col(uid, 'goals').doc(goalId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DASHBOARD / STATISTICS
  // ═══════════════════════════════════════════════════════════════════════

  /// Tính tổng thu/chi trong khoảng thời gian
  static Future<Map<String, double>> getSummary(
      String uid, DateTime from, DateTime to) async {
    final txs = await getTransactions(uid, from: from, to: to);
    double income = 0, expense = 0;
    for (final tx in txs) {
      if (tx.type == 'INCOME') {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return {
      'income': income,
      'expense': expense,
      'saving': income - expense,
    };
  }

  /// Chi tiêu theo danh mục (cho báo cáo)
  static Future<Map<String, double>> getExpenseByCategory(
      String uid, DateTime from, DateTime to) async {
    final txs = await getTransactions(uid,
        type: 'EXPENSE', from: from, to: to);
    final Map<String, double> result = {};
    for (final tx in txs) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return result;
  }

  /// Thu nhập theo danh mục (cho báo cáo)
  static Future<Map<String, double>> getIncomeByCategory(
      String uid, DateTime from, DateTime to) async {
    final txs = await getTransactions(uid,
        type: 'INCOME', from: from, to: to);
    final Map<String, double> result = {};
    for (final tx in txs) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return result;
  }

  /// Dữ liệu theo ngày trong tháng
  static Future<Map<int, Map<String, double>>> getDailyData(
      String uid, int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    final txs = await getTransactions(uid, from: from, to: to);
    final Map<int, Map<String, double>> result = {};
    for (final tx in txs) {
      final day = tx.date.day;
      result[day] ??= {'income': 0, 'expense': 0};
      if (tx.type == 'INCOME') {
        result[day]!['income'] = (result[day]!['income'] ?? 0) + tx.amount;
      } else {
        result[day]!['expense'] = (result[day]!['expense'] ?? 0) + tx.amount;
      }
    }
    return result;
  }

  /// Dữ liệu theo tháng trong năm
  static Future<List<Map<String, dynamic>>> getMonthlyData(
      String uid, int year) async {
    final from = DateTime(year, 1, 1);
    final to = DateTime(year, 12, 31, 23, 59, 59);
    final txs = await getTransactions(uid, from: from, to: to);

    final Map<int, Map<String, double>> monthly = {};
    for (int i = 1; i <= 12; i++) {
      monthly[i] = {'income': 0, 'expense': 0};
    }
    for (final tx in txs) {
      final m = tx.date.month;
      if (tx.type == 'INCOME') {
        monthly[m]!['income'] = (monthly[m]!['income'] ?? 0) + tx.amount;
      } else {
        monthly[m]!['expense'] = (monthly[m]!['expense'] ?? 0) + tx.amount;
      }
    }
    return List.generate(12, (i) => {
      'month': i + 1,
      'income': monthly[i + 1]!['income']!,
      'expense': monthly[i + 1]!['expense']!,
      'saving': monthly[i + 1]!['income']! - monthly[i + 1]!['expense']!,
    });
  }

  /// Transactions theo ngày (cho calendar view)
  static Future<Map<DateTime, List<TransactionModel>>> getTransactionsByDate(
      String uid, DateTime from, DateTime to) async {
    final txs = await getTransactions(uid, from: from, to: to);
    final Map<DateTime, List<TransactionModel>> result = {};
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      result[day] ??= [];
      result[day]!.add(tx);
    }
    return result;
  }
}
