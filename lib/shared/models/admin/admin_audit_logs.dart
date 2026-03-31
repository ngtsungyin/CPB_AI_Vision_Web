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
    return AdminAuditLog(
      logId: map['logid']?.toString() ?? '',
      adminEmail: map['adminemail']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      targetType: map['targettype']?.toString(),
      targetId: map['targetid']?.toString(),
      details: map['details']?.toString(),
      logTime: map['logtime'] != null
          ? DateTime.parse(map['logtime'].toString())
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