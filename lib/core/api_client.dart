import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:async' show TimeoutException;

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  static const _timeout = Duration(seconds: 30);

  // ── GET ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String url) async {
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers(token),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Không thể kết nối tới server');
    } on TimeoutException {
      throw const ApiException('Kết nối quá thời gian');
    }
  }

  // ── POST ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final token = withAuth ? await TokenStorage.getAccessToken() : null;
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Không thể kết nối tới server');
    } on TimeoutException {
      throw const ApiException('Kết nối quá thời gian');
    }
  }

  // ── PUT ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Không thể kết nối tới server');
    } on TimeoutException {
      throw const ApiException('Kết nối quá thời gian');
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(String url) async {
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _headers(token),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('Không thể kết nối tới server');
    } on TimeoutException {
      throw const ApiException('Kết nối quá thời gian');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ??
        'Lỗi ${response.statusCode}: Yêu cầu không thành công';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
