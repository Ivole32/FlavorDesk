import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_page.dart';
import 'token_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<Map<String, dynamic>> _userAndProjectsFuture;

  @override
  void initState() {
    super.initState();
    _userAndProjectsFuture = _fetchUserAndProjects();
  }

  Future<Map<String, dynamic>> _fetchUserAndProjects() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userJson = {};
    List<Map<String, dynamic>> projects = [];
    if (prefs.containsKey('user_cache')) {
      final cachedUser = prefs.getString('user_cache');
      if (cachedUser != null) {
        userJson = jsonDecode(cachedUser);
      }
    }
    if (prefs.containsKey('projects_cache')) {
      final cachedProjects = prefs.getString('projects_cache');
      if (cachedProjects != null) {
        final decoded = jsonDecode(cachedProjects);
        if (decoded is List) {
          projects = List<Map<String, dynamic>>.from(decoded);
        }
      }
    }
    return {'user': userJson, 'projects': projects};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _userAndProjectsFuture,
        builder: (context, snapshot) {
          final user = snapshot.data?['user'];
          return Drawer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary.withOpacity(0.9), Theme.of(context).colorScheme.secondary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    accountName: Text(user?['display_name'] ?? 'Welcome!'),
                    accountEmail: const Text('FlavorDesk User'),
                    currentAccountPicture: user?['avatar'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar']),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.folder_special_rounded, color: Colors.blueAccent),
                        title: const Text('Projects', style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.settings_rounded, color: Colors.deepPurple),
                        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'FlavorDesk v1.0',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userAndProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading projects'));
          }
          final projects = snapshot.data?['projects'] ?? [];
          if (projects.isEmpty) {
            return const Center(child: Text('No projects found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final url = project['demo_url']?.isNotEmpty == true
                      ? project['demo_url']
                      : project['repo_url'];
                  if (url != null && url.isNotEmpty) {
                    launchUrl(Uri.parse(url));
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project['description'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            if ((project['repo_url'] ?? '').isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  final url = project['repo_url'];
                                  if (url != null && url.isNotEmpty) {
                                    launchUrl(Uri.parse(url));
                                  }
                                },
                                child: const Text('Repository'),
                              ),
                            if ((project['demo_url'] ?? '').isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  final url = project['demo_url'];
                                  if (url != null && url.isNotEmpty) {
                                    launchUrl(Uri.parse(url));
                                  }
                                },
                                child: const Text('Demo'),
                              ),
                            if ((project['readme_url'] ?? '').isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  final url = project['readme_url'];
                                  if (url != null && url.isNotEmpty) {
                                    launchUrl(Uri.parse(url));
                                  }
                                },
                                child: const Text('README'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// End of file