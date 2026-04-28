class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String? userId;
  final String? userEmail;
  final String type;
  bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    this.userId,
    this.userEmail,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'].toString(),
      title: json['title'].toString(),
      message: json['message'].toString(),
      userId: json['user_id']?.toString(),
      userEmail: json['user_email']?.toString(),
      type: json['type'].toString(),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'user_id': userId,
      'user_email': userEmail,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}