class AdminAuditLog {
  final String logId;
  final String adminEmail;
  final String action;
  final String? targetType;
  final String? targetId;
  final String? details;
  final DateTime logTime;

  AdminAuditLog({
    required this.logId,
    required this.adminEmail,
    required this.action,
    this.targetType,
    this.targetId,
    this.details,
    required this.logTime,
  });

  factory AdminAuditLog.fromMap(Map<String, dynamic> map) {
    final rawLogTime = map['logtime'] ?? map['log_time'] ?? map['created_at'];

    return AdminAuditLog(
      logId: (map['logid'] ?? map['log_id'] ?? '').toString(),
      adminEmail: (map['adminemail'] ?? map['admin_email'] ?? '').toString(),
      action: (map['action'] ?? '').toString(),
      targetType: (map['targettype'] ?? map['target_type'])?.toString(),
      targetId: (map['targetid'] ?? map['target_id'])?.toString(),
      details: (map['details'] ?? '').toString(),
      logTime: rawLogTime != null
          ? DateTime.tryParse(rawLogTime.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logid': logId,
      'adminemail': adminEmail,
      'action': action,
      'targettype': targetType,
      'targetid': targetId,
      'details': details,
      'logtime': logTime.toIso8601String(),
    };
  }
}