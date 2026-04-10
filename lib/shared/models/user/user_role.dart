enum UserRole {
  farmer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.admin:
        return 'Admin';
    }
  }
}