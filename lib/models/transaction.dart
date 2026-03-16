import 'category.dart';
import 'account.dart'; // import để dùng class Jar

class TransactionModel {
  final int? id;
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String type; // 'INCOME' hoặc 'EXPENSE'
  final Jar? jar;
  final Category? category;

  TransactionModel({
    this.id,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.type,
    this.jar,
    this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note'],
      transactionDate: DateTime.parse(json['transactionDate']),
      type: json['type'],
      jar: json['jar'] != null ? Jar.fromJson(json['jar']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'transactionDate': transactionDate.toIso8601String(),
      'type': type,
      'jar': jar?.toJson(),
      'category': category?.toJson(),
    };
  }
}