// user_audit_log_service.dart
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class UserAuditLogService extends BaseSupabaseService {
  Future<List<UserAuditLog>> getAllUserAuditLogs() async {
    try {
      final response = await client
          .from('user_audit_logs')
          .select()
          .order('created_at', ascending: false);

      final logs = (response as List<dynamic>)
          .map((e) => UserAuditLog.fromMap(e as Map<String, dynamic>))
          .toList();

      print('User audit logs fetched: ${logs.length}');
      return logs;
    } catch (e) {
      logError('Error getting all user audit logs', e);
      rethrow;
    }
  }
}
