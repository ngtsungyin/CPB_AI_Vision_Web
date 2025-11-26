// lib/services/auth_manager.dart
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  bool _isLoggedIn = false;
  String? _currentAdminEmail;

  // Hardcoded admin credentials
  final String _adminEmail = "ngtsungyin@gmail.com";
  final String _adminPassword = "dmcocoa";

  bool verifyCredentials(String email, String password) {
    return email == _adminEmail && password == _adminPassword;
  }

  void login(String email) {
    _isLoggedIn = true;
    _currentAdminEmail = email;
  }

  void logout() {
    _isLoggedIn = false;
    _currentAdminEmail = null;
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get currentAdminEmail => _currentAdminEmail;
}