class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  bool _isLoggedIn = false;
  String? _currentAdminEmail;

// Hardcoded admin credentials
final List<Map<String, String>> _adminCredentials = [
  {"email": "ngtsungyin@gmail.com", "password": "dmcocoa"},
  {"email": "chocsweetlollipop@gmail.com", "password": "dmcocoa"},
  {"email": "third_admin@company.com", "password": "another_password"},
  // Add more admins here
];

bool verifyCredentials(String email, String password) {
  for (var admin in _adminCredentials) {
    if (email == admin["email"] && password == admin["password"]) {
      return true;
    }
  }
  return false;
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