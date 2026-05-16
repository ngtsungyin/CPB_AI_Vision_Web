// user_audit_log.dart
import 'dart:convert';

class UserAuditLog {
  final String logId;
  final String farmerName;
  final String phoneNumber;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? payload;
  final DateTime logTime;

  UserAuditLog({
    required this.logId,
    required this.farmerName,
    required this.phoneNumber,
    required this.action,
    required this.entityType,
    this.entityId,
    this.payload,
    required this.logTime,
  });

  factory UserAuditLog.fromMap(Map<String, dynamic> map) {
    final rawLogTime = map['created_at'] ?? map['log_time'] ?? map['logtime'];

    Map<String, dynamic>? parsedPayload;
    if (map['payload'] != null) {
      if (map['payload'] is Map) {
        parsedPayload = Map<String, dynamic>.from(map['payload']);
      } else if (map['payload'] is String) {
        try {
          parsedPayload = jsonDecode(map['payload']);
        } catch (_) {}
      }
    }

    return UserAuditLog(
      logId: (map['log_id'] ?? map['logid'] ?? '').toString(),
      farmerName: (map['farmer_name'] ?? 'Unknown').toString(),
      phoneNumber: (map['phone_number'] ?? 'Unknown').toString(),
      action: (map['action'] ?? '').toString(),
      entityType: (map['entity_type'] ?? '').toString(),
      entityId: (map['entity_id'] ?? map['entityid'])?.toString(),
      payload: parsedPayload,
      logTime: rawLogTime != null
          ? DateTime.tryParse(rawLogTime.toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
    );
  }
}
