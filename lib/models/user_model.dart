class UserModel {
  final int userId;
  final String fullName;
  final String email;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId:   json['userId']   as int,
      fullName: json['fullName'] as String,
      email:    json['email']    as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId':   userId,
        'fullName': fullName,
        'email':    email,
      };
}
