// lib/pages/auth_callback.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_panel.dart';
import 'admin_login.dart';

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      print('🔐 Callback page loaded');

      // Get the session from the URL - this is the correct method for v2.10.3
      final response = await Supabase.instance.client.auth.getSessionFromUrl(
        Uri.base,
      );

      print('✅ Session received: ${response.session != null}');

      if (response.session != null && mounted) {
        print('✅ User logged in: ${response.session!.user.email}');

        // Navigate to admin panel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanel()),
        );
      } else {
        print('❌ No session');
        _goBackToLogin();
      }
    } catch (e) {
      print('❌ Error: $e');
      _goBackToLogin();
    }
  }

  void _goBackToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Verifying your login...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}