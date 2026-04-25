class AdminNotification {
  String id;
  String adminId;
  String type;
  String title;
  String message;
  String? relatedUserId;
  bool isRead;
  DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.adminId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedUserId,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'].toString(),
      adminId: json['admin_id'].toString(),
      type: json['type'].toString(),
      title: json['title'].toString(),
      message: json['message'].toString(),
      relatedUserId: json['related_user_id']?.toString(),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'type': type,
      'title': title,
      'message': message,
      'related_user_id': relatedUserId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}