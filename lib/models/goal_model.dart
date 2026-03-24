// lib/models/goal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? icon;
  final String? color;
  final String? note;
  final DateTime? createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.icon,
    this.color,
    this.note,
    this.createdAt,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentAmount >= targetAmount;

  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  factory GoalModel.fromFirestore(Map<String, dynamic> d, String id) =>
      GoalModel(
        id: id,
        title: d['title'] as String,
        targetAmount: (d['targetAmount'] as num).toDouble(),
        currentAmount: (d['currentAmount'] as num? ?? 0).toDouble(),
        deadline: (d['deadline'] as Timestamp?)?.toDate(),
        icon: d['icon'] as String?,
        color: d['color'] as String?,
        note: d['note'] as String?,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        if (deadline != null) 'deadline': Timestamp.fromDate(deadline!),
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (note != null) 'note': note,
      };
}
