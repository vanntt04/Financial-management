class User {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime? createdAt;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}