class AppUser {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String accountStatus;
  final List<String> farms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  AppUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.accountStatus,
    required this.farms,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userid']?.toString() ?? '',
      firstName: map['firstname']?.toString() ?? '',
      lastName: map['lastname']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phoneNumber: map['phonenumber']?.toString(),
      role: map['role']?.toString() ?? 'farmer',
      accountStatus: map['accountstatus']?.toString() ?? 'pending_verification',
      farms: List<String>.from(map['farms'] ?? []),
      createdAt: map['createdat'] != null
          ? DateTime.parse(map['createdat'].toString())
          : DateTime.now(),
      updatedAt: map['updatedat'] != null
          ? DateTime.parse(map['updatedat'].toString())
          : DateTime.now(),
      lastLoginAt: map['lastloginat'] != null
          ? DateTime.parse(map['lastloginat'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userid': userId,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'phonenumber': phoneNumber,
      'role': role,
      'accountstatus': accountStatus,
      'farms': farms,
      'createdat': createdAt.toIso8601String(),
      'updatedat': updatedAt.toIso8601String(),
      'lastloginat': lastLoginAt?.toIso8601String(),
    };
  }
}