import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class AdminAuditLogService extends BaseSupabaseService {
  Future<List<AdminAuditLog>> getAllAuditLogs() async {
    try {
      final response = await client
          .from('admin_audit_logs')
          .select('logid, adminemail, action, targettype, targetid, details, logtime')
          .order('logtime', ascending: false);

      final logs = (response as List<dynamic>)
          .map((e) => AdminAuditLog.fromMap(e as Map<String, dynamic>))
          .toList();

      print('Audit logs fetched: ${logs.length}');
      return logs;
    } catch (e) {
      logError('Error getting all audit logs', e);
      rethrow;
    }
  }

  Future<bool> createAuditLog(AdminAuditLog log) async {
    try {
      await client.from('admin_audit_logs').insert(log.toMap());
      return true;
    } catch (e) {
      logError('Error creating audit log', e);
      return false;
    }
  }
}