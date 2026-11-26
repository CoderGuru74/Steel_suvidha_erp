import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef JsonMap = Map<String, dynamic>;
typedef HeaderMap = Map<String, String>;

class ErpApiClient {
  ErpApiClient._();
  static final ErpApiClient instance = ErpApiClient._();

  static const _tokenKey = 'steel_suvidha_jwt_token';

  String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<HeaderMap> _headers() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<JsonMap> get(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _decode(res);
  }

  Future<JsonMap> post(
    String path,
    JsonMap body,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  JsonMap _decode(http.Response res) {
    final decoded = res.body.isNotEmpty
        ? jsonDecode(res.body) as JsonMap
        : <String, dynamic>{};
    if (res.statusCode >= 400) {
      throw Exception(decoded['error'] ?? 'Request failed (${res.statusCode})');
    }
    return decoded;
  }
}