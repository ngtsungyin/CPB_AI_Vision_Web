import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/features/auth/services/session_notice.dart';
import 'package:cpbaivision_app/features/auth/services/session_timeout_wrapper.dart';
import 'package:cpbaivision_app/features/auth/pages/admin_login.dart';
import 'package:cpbaivision_app/features/dashboard/pages/admin_panel.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSub;
  bool _isBootstrapping = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _bootstrapSession();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      setState(() {
        _session = data.session;
      });
    });
  }

  Future<void> _bootstrapSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _session = Supabase.instance.client.auth.currentSession;
      _isBootstrapping = false;
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return const _LoadingSplashScreen();
    }

    if (_session != null) {
      return const SessionTimeoutWrapper(
        timeout: Duration(minutes: 15),
        child: AdminPanel(),
      );
    }

    return const AdminLoginPage();
  }
}

class _LoadingSplashScreen extends StatelessWidget {
  const _LoadingSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'CPB AI Vision Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Restoring secure session...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}