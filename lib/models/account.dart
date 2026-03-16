class Account {
  final int? id;
  final double totalBalance;
  final List<Jar> jars;

  Account({
    this.id,
    required this.totalBalance,
    this.jars = const [],
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      jars: json['jars'] != null
          ? (json['jars'] as List).map((i) => Jar.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalBalance': totalBalance,
      'jars': jars.map((jar) => jar.toJson()).toList(),
    };
  }
}

class Jar {
  final int? id;
  final String name;
  final double percentage;
  final double currentAmount;
  final String type; // 'SPENDING' hoặc 'SAVING'

  Jar({
    this.id,
    required this.name,
    required this.percentage,
    required this.currentAmount,
    required this.type,
  });

  factory Jar.fromJson(Map<String, dynamic> json) {
    return Jar(
      id: json['id'],
      name: json['name'],
      percentage: (json['percentage'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
      'currentAmount': currentAmount,
      'type': type,
    };
  }
}