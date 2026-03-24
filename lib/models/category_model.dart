// lib/models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // INCOME | EXPENSE
  final String? icon;
  final String? color;
  final bool isDefault;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isDefault = false,
    this.createdAt,
  });

  bool get isIncome => type == 'INCOME';
  bool get isExpense => type == 'EXPENSE';

  factory CategoryModel.fromFirestore(Map<String, dynamic> d, String id) =>
      CategoryModel(
        id: id,
        name: d['name'] as String,
        type: d['type'] as String,
        icon: d['icon'] as String?,
        color: d['color'] as String?,
        isDefault: d['isDefault'] as bool? ?? false,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        'isDefault': isDefault,
      };
}

// lib/models/account_model.dart — included in same file for brevity
// (split into separate files in your project)
