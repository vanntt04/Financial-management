class Category {
  final int? id;
  final String name;
  final String type; // 'INCOME' hoặc 'EXPENSE'
  final String? icon;
  final String? color;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }
}