import 'package:supabase_flutter/supabase_flutter.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String? _currentAdminEmail;
  String? _currentUserId;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String? get currentAdminEmail => _currentAdminEmail;
  String? get currentUserId => _currentUserId;

  Future<void> initializeFromSession() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _clearLocalState();
      return;
    }

    _currentUserId = user.id;
    _currentAdminEmail = user.email;
    _isAdmin = await checkIsAdmin(user.id);
    _isLoggedIn = _isAdmin;
  }

  Future<bool> checkIsAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role, is_active')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return false;

      final role = response['role']?.toString().toLowerCase();
      final isActive = response['is_active'] == true;

      return role == 'admin' && isActive;
    } catch (_) {
      return false;
    }
  }

  Future<bool> loginFromCurrentSession() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _clearLocalState();
      return false;
    }

    final isApprovedAdmin = await checkIsAdmin(user.id);

    if (!isApprovedAdmin) {
      _clearLocalState();
      return false;
    }

    _isLoggedIn = true;
    _isAdmin = true;
    _currentUserId = user.id;
    _currentAdminEmail = user.email;
    return true;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _clearLocalState();
  }

  void _clearLocalState() {
    _isLoggedIn = false;
    _isAdmin = false;
    _currentAdminEmail = null;
    _currentUserId = null;
  }
}