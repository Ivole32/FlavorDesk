import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthService {
  static const String _url =
      'https://flavortown.hackclub.com/api/v1/projects';

  static Future<bool> validateToken() async {
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}