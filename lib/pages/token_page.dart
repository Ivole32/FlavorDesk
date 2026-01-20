import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import 'main_page.dart';

class TokenPage extends StatefulWidget {
  const TokenPage({super.key});

  @override
  State<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndValidate() async {
    final token = _controller.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    await TokenStorage.saveToken(token);
    final valid = await AuthService.validateToken();

    if (!mounted) return;

    if (valid) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (_) => false,
      );
    } else {
      await TokenStorage.deleteToken();
      setState(() {
        _loading = false;
        _error = 'Invalid API token';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Token')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your API token',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _controller.text.isEmpty || _loading
                  ? null
                  : _saveAndValidate,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Validate & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}