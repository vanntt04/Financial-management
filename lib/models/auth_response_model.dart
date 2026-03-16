import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken:  json['accessToken']  as String,
      refreshToken: json['refreshToken'] as String,
      tokenType:    json['tokenType']    as String? ?? 'Bearer',
      expiresIn:    json['expiresIn']    as int?    ?? 86400,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
