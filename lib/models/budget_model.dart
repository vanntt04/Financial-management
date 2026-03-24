import 'category_model.dart';

class BudgetModel {
  final int? id;
  final double limitAmount;
  final double spentAmount;
  final String period; // 'MONTHLY', 'WEEKLY', 'DAILY'
  final DateTime startDate;
  final DateTime endDate;
  final CategoryModel? category;

  BudgetModel({
    this.id,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.category,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      limitAmount: (json['limitAmount'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      period: json['period'] ?? 'MONTHLY',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: json['category'] != null 
          ? CategoryModel.fromJson(json['category']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryId': category?.categoryId,
    };
  }

  double get remainingAmount => limitAmount - spentAmount;
  double get progress => limitAmount > 0 ? (spentAmount / limitAmount) : 0;
}
