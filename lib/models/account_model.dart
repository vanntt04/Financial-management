// lib/models/account_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String name;
  final double balance;
  final double? allocationPercent;
  final bool isGoalActive;
  final double? targetAmount;
  final DateTime? createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    this.allocationPercent,
    this.isGoalActive = false,
    this.targetAmount,
    this.createdAt,
  });

  double get progress =>
      (isGoalActive && targetAmount != null && targetAmount! > 0)
          ? (balance / targetAmount!).clamp(0.0, 1.0)
          : 0.0;

  factory AccountModel.fromFirestore(Map<String, dynamic> d, String id) =>
      AccountModel(
        id: id,
        name: d['name'] as String,
        balance: (d['balance'] as num? ?? 0).toDouble(),
        allocationPercent:
            (d['allocationPercent'] as num?)?.toDouble(),
        isGoalActive: d['isGoalActive'] as bool? ?? false,
        targetAmount: (d['targetAmount'] as num?)?.toDouble(),
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'balance': balance,
        if (allocationPercent != null) 'allocationPercent': allocationPercent,
        'isGoalActive': isGoalActive,
        if (targetAmount != null) 'targetAmount': targetAmount,
      };
}
