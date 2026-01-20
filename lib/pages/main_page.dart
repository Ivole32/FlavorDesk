import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'token_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<String?> _loadToken() {
    return TokenStorage.readToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await TokenStorage.deleteToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TokenPage()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _loadToken(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Authenticated successfully',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  snapshot.data!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}