class FinancialGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? icon;

  FinancialGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.icon,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      name: json['name'],
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
    };
  }
}