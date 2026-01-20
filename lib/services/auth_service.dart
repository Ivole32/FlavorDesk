import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage.dart';

class AuthService {
  static const String _userUrl =
      'https://flavortown.hackclub.com/api/v1/users/me';
  static const String _projectBaseUrl =
      'https://flavortown.hackclub.com/api/v1/projects/';

  static Future<bool> validateToken() async {
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse(_userUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<int>> fetchUserProjectIds() async {
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) return [];
    try {
      final response = await http.get(
        Uri.parse(_userUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = response.body;
        final json = data != null ? jsonDecode(data) : null;
        if (json != null && json['project_ids'] is List) {
          return List<int>.from(json['project_ids']);
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> fetchProject(int id) async {
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('$_projectBaseUrl$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = response.body;
        final json = data != null ? jsonDecode(data) : null;
        if (json != null && json is Map<String, dynamic>) {
          return json;
        }
      }
    } catch (_) {}
    return null;
  }
}