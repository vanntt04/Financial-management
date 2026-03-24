// lib/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // INCOME | EXPENSE
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountId;
  final String? accountName;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountId,
    this.accountName,
    this.note,
    required this.date,
    this.createdAt,
  });

  bool get isIncome => type == 'INCOME';
  bool get isExpense => type == 'EXPENSE';

  factory TransactionModel.fromFirestore(Map<String, dynamic> d, String id) =>
      TransactionModel(
        id: id,
        amount: (d['amount'] as num).toDouble(),
        type: d['type'] as String,
        categoryId: d['categoryId'] as String? ?? '',
        categoryName: d['categoryName'] as String? ?? '',
        categoryIcon: d['categoryIcon'] as String?,
        categoryColor: d['categoryColor'] as String?,
        accountId: d['accountId'] as String?,
        accountName: d['accountName'] as String?,
        note: d['note'] as String?,
        date: (d['date'] as Timestamp).toDate(),
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'categoryId': categoryId,
        'categoryName': categoryName,
        if (categoryIcon != null) 'categoryIcon': categoryIcon,
        if (categoryColor != null) 'categoryColor': categoryColor,
        if (accountId != null) 'accountId': accountId,
        if (accountName != null) 'accountName': accountName,
        if (note != null) 'note': note,
        'date': Timestamp.fromDate(date),
      };
}
