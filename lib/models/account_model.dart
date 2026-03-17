class AccountModel {
  final int? id;
  final String name;
  final double percentage;
  final double currentAmount;
  final String type; // 'SPENDING' | 'SAVING'
  final bool isGoalActive;
  final double? targetAmount;
  final String? targetDate;

  const AccountModel({
    this.id,
    required this.name,
    required this.percentage,
    required this.currentAmount,
    required this.type,
    this.isGoalActive = false,
    this.targetAmount,
    this.targetDate,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
        currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
        type: json['type'] as String? ?? 'SPENDING',
        isGoalActive: json['isGoalActive'] as bool? ?? false,
        targetAmount: (json['targetAmount'] as num?)?.toDouble(),
        targetDate: json['targetDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'percentage': percentage,
        'currentAmount': currentAmount,
        'type': type,
        'isGoalActive': isGoalActive,
        'targetAmount': targetAmount,
        'targetDate': targetDate,
      };

  AccountModel copyWith({
    int? id,
    String? name,
    double? percentage,
    double? currentAmount,
    String? type,
    bool? isGoalActive,
    double? targetAmount,
    String? targetDate,
  }) =>
      AccountModel(
        id: id ?? this.id,
        name: name ?? this.name,
        percentage: percentage ?? this.percentage,
        currentAmount: currentAmount ?? this.currentAmount,
        type: type ?? this.type,
        isGoalActive: isGoalActive ?? this.isGoalActive,
        targetAmount: targetAmount ?? this.targetAmount,
        targetDate: targetDate ?? this.targetDate,
      );
}
