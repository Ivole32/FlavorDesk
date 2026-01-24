import 'package:flutter/material.dart';

import '../services/token_storage.dart';
import 'token_page.dart';
import '../main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = themeNotifier.value == ThemeMode.dark;
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          drawer: Drawer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary.withValues(alpha: 0.9), Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7)],
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
                    currentAccountPicture: (user['avatar'] != null && (user['avatar'] as String).isNotEmpty)
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar'] as String),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.folder_special_rounded, color: Colors.blueAccent),
                        title: const Text('Projects', style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.settings_rounded, color: Colors.deepPurple),
                        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'FlavorDesk v1.0',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            const SizedBox(height: 24),
            const Text('Change API Key', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(hintText: 'New API Key'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await TokenStorage.saveToken(_apiKeyController.text);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_cache');
                await prefs.remove('user_cache_time');
                await prefs.remove('projects_cache');
                await prefs.remove('projects_cache_time');
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const TokenPage()),
                    (_) => false,
                  );
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await TokenStorage.deleteToken();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout')
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user_cache')) {
      final cachedUser = prefs.getString('user_cache');
      if (cachedUser != null) {
        return Map<String, dynamic>.from(jsonDecode(cachedUser));
      }
    }
    return <String, dynamic>{};
  }
}