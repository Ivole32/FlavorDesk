import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'services/token_storage.dart';
import 'services/auth_service.dart';

class BackgroundDataFetcher {
  static Timer? _timer;

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateUserAndProjects();
    });
    // Initial fetch
    _updateUserAndProjects();
  }

  static Future<void> _updateUserAndProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) return;
    // User fetch
    final userResponse = await http.get(
      Uri.parse('https://flavortown.hackclub.com/api/v1/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    Map<String, dynamic> userJson = {};
    List<int> ids = [];
    if (userResponse.statusCode == 200) {
      userJson = jsonDecode(userResponse.body);
      prefs.setString('user_cache', userResponse.body);
      prefs.setInt('user_cache_time', DateTime.now().millisecondsSinceEpoch);
      if (userJson['project_ids'] is List) {
        ids = List<int>.from(userJson['project_ids']);
      }
    }
    // Projects fetch
    List<Map<String, dynamic>> projects = [];
    for (final id in ids) {
      final project = await AuthService.fetchProject(id);
      if (project != null) {
        projects.add(project);
      }
    }
    prefs.setString('projects_cache', jsonEncode(projects));
    prefs.setInt('projects_cache_time', DateTime.now().millisecondsSinceEpoch);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
