class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;

  const UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        if (phone != null) 'phone': phone,
      };
}
