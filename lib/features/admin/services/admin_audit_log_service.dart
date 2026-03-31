import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class AdminAuditLogService extends BaseSupabaseService {
  
  /// Fetches all audit logs from the database, newest first.
  Future<List<AdminAuditLog>> getAllAuditLogs() async {
    try {
      final response = await client
          // Make sure 'admin_audit_logs' matches your exact Supabase table name!
          .from('admin_audit_logs') 
          .select()
          .order('logtime', ascending: false);

      return (response as List<dynamic>)
          .map((e) => AdminAuditLog.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all audit logs', e);
      return [];
    }
  }

  /// Inserts a new audit log into the database.
  /// Call this whenever an admin performs a sensitive action (create, update, delete).
  Future<bool> createAuditLog(AdminAuditLog log) async {
    try {
      await client
          .from('admin_audit_logs')
          .insert(log.toMap());
      return true;
    } catch (e) {
      logError('Error creating audit log', e);
      return false;
    }
  }
}