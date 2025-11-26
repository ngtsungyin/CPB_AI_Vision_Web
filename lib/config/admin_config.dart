// lib/config/admin_config.dart
class AdminConfig {
  // Store admin emails in a list for future multiple admins
  static const List<String> adminEmails = [
    'ngtsungyin@gmail.com',
    // Add more admin emails here in the future
  ];

  // Store other admin-specific settings here
  static const String appName = 'Cocoa Farm Management';
  static const String supportEmail = 'ngtsungyin@gmail.com';

  // Method to check if email is admin
  static bool isAdminEmail(String email) {
    return adminEmails.contains(email.toLowerCase().trim());
  }
}