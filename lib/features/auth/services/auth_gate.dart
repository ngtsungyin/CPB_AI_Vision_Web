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

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isBootstrapping = true;
  Session? _session;
  bool _isAuthorizedAdmin = false;

  @override
  void initState() {
    super.initState();
    _bootstrapSession();

    _authSub = _supabase.auth.onAuthStateChange.listen((data) async {
      await _handleSessionChange(data.session);
    });
  }

  Future<void> _bootstrapSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final currentSession = _supabase.auth.currentSession;
    await _handleSessionChange(currentSession, isInitialLoad: true);
  }

  Future<void> _handleSessionChange(
    Session? session, {
    bool isInitialLoad = false,
  }) async {
    if (!mounted) return;

    if (session == null) {
      setState(() {
        _session = null;
        _isAuthorizedAdmin = false;
        _isBootstrapping = false;
      });
      return;
    }

    final isAdmin = await _checkIsApprovedAdmin();

    if (!mounted) return;

    if (!isAdmin) {
      SessionNotice.show(
        'This account is not authorized to access the admin panel.',
      );

      await _supabase.auth.signOut();

      if (!mounted) return;

      setState(() {
        _session = null;
        _isAuthorizedAdmin = false;
        _isBootstrapping = false;
      });

      return;
    }

    setState(() {
      _session = session;
      _isAuthorizedAdmin = true;
      _isBootstrapping = false;
    });
  }

  Future<bool> _checkIsApprovedAdmin() async {
    final user = _supabase.auth.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user == null || email == null || email.isEmpty) {
      return false;
    }

    try {
      final record = await _supabase
          .from('users')
          .select('email, role, accountstatus')
          .eq('email', email)
          .maybeSingle();

      if (record == null) {
        return false;
      }

      final role = (record['role'] ?? '').toString().trim().toLowerCase();
      final accountStatus =
          (record['accountstatus'] ?? '').toString().trim().toLowerCase();

      return role == 'admin' && accountStatus == 'approved';
    } catch (_) {
      return false;
    }
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

    if (_session != null && _isAuthorizedAdmin) {
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
      backgroundColor: Color(0xFFF9FAFB),
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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF111827), Color(0xFF374151)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                  color: Color(0xFF111827),
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