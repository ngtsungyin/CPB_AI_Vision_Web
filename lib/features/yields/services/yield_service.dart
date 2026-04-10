import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';
// Import the audit service and uuid
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';
import 'package:uuid/uuid.dart';

class YieldService extends BaseSupabaseService {
  // Initialize the audit log service
  final AdminAuditLogService _auditLogService = AdminAuditLogService();
  final Uuid _uuid = const Uuid();

  Future<List<YieldRecord>> getAllYieldRecords() async {
    try {
      final response = await client
          .from('yield_records')
          .select()
          .order('harvestdate', ascending: false);

      return (response as List<dynamic>)
          .map((e) => YieldRecord.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all yield records', e);
      return [];
    }
  }

  // --- MUTATION METHODS (These get audited!) ---

  Future<bool> deleteYieldRecord(String recordId, String adminEmail) async {
    try {
      await client
          .from('yield_records')
          .delete()
          .eq('recordid', recordId.toLowerCase());

      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'DELETE',
        targetType: 'YieldRecord',
        targetId: recordId,
        details: 'Deleted a yield record',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error deleting yield record', e);
      return false;
    }
  }
}