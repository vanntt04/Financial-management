import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  static String get _base {
    if (kIsWeb) return 'http://localhost:8080/api';
    return 'http://10.0.2.2:8080/api'; // Android emulator
  }

  // ── GET ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$_base$path')
        .replace(queryParameters: queryParams);
    final headers = await _headers(withAuth: withAuth);
    final res = await http.get(uri, headers: headers);
    return _parse(res);
  }

  // ── POST ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$_base$path');
    final headers = await _headers(withAuth: withAuth);
    final res = await http.post(uri,
        headers: headers, body: jsonEncode(body));
    return _parse(res);
  }

  // ── PUT ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final headers = await _headers(withAuth: withAuth);
    final res = await http.put(uri,
        headers: headers, body: jsonEncode(body));
    return _parse(res);
  }

  // ── DELETE ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(
    String path, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final headers = await _headers(withAuth: withAuth);
    final res = await http.delete(uri, headers: headers);
    return _parse(res);
  }

  // ── Helpers ───────────────────────────────────────────────
  static Future<Map<String, String>> _headers(
      {bool withAuth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body as Map<String, dynamic>;
    }
    final msg = (body is Map ? body['message'] : null) ??
        'Lỗi server: ${res.statusCode}';
    throw ApiException(msg, statusCode: res.statusCode);
  }
}
