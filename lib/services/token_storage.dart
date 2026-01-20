import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _key = 'api_token';

  static Future<String?> readToken() {
    return _storage.read(key: _key);
  }

  static Future<void> saveToken(String token) {
    return _storage.write(key: _key, value: token);
  }

  static Future<void> deleteToken() {
    return _storage.delete(key: _key);
  }
}