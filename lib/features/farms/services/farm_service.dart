import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';
// Import the audit service and uuid
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';
import 'package:uuid/uuid.dart';

class FarmService extends BaseSupabaseService {
  // Initialize the audit log service
  final AdminAuditLogService _auditLogService = AdminAuditLogService();
  final Uuid _uuid = const Uuid();

  // --- READ/CREATE METHODS (No admin auditing needed) ---

  Future<List<Farm>> getUserFarms(String userId) async {
    try {
      final response = await client
          .from('farms')
          .select()
          .eq('ownerid', userId.toLowerCase());

      return (response as List<dynamic>)
          .map((e) => Farm.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting farms', e);
      return [];
    }
  }

  Future<bool> createFarm(Farm farm) async {
    try {
      await client.from('farms').insert(farm.toMap());
      return true;
    } catch (e) {
      logError('Error creating farm', e);
      return false;
    }
  }

  Future<List<Farm>> getAllFarms() async {
    try {
      final response = await client
          .from('farms')
          .select()
          .order('createdat', ascending: false);

      return (response as List<dynamic>)
          .map((e) => Farm.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all farms', e);
      return [];
    }
  }

  Future<Farm?> getFarmById(String farmId) async {
    try {
      final response = await client
          .from('farms')
          .select()
          .eq('farmid', farmId.toLowerCase())
          .single();

      return Farm.fromMap(response);
    } catch (e) {
      logError('Error getting farm by ID', e);
      return null;
    }
  }

  // --- MUTATION METHODS (These get audited!) ---

  Future<bool> updateFarmStatus(String farmId, bool isActive, String adminEmail) async {
    try {
      await client.from('farms').update({
        'isactive': isActive,
        'updatedat': DateTime.now().toIso8601String(),
      }).eq('farmid', farmId.toLowerCase());

      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'UPDATE',
        targetType: 'Farm',
        targetId: farmId,
        details: 'Changed farm active status to: $isActive',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error updating farm status', e);
      return false;
    }
  }

  Future<bool> deleteFarm(String farmId, String adminEmail) async {
    try {
      await client.from('farms').delete().eq('farmid', farmId.toLowerCase());
      
      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'DELETE',
        targetType: 'Farm',
        targetId: farmId,
        details: 'Deleted farm record',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error deleting farm', e);
      return false;
    }
  }

  Future<bool> updateFarm(Farm farm, String adminEmail) async {
    try {
      await client
          .from('farms')
          .update({
            'farmname': farm.farmName,
            'state': farm.state,
            'district': farm.district,
            'village': farm.village,
            'postcode': farm.postcode,
            'areahectares': farm.areaHectares,
            'treecount': farm.treeCount,
            'updatedat': DateTime.now().toIso8601String(),
          })
          .eq('farmid', farm.farmId.toLowerCase());

      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'UPDATE',
        targetType: 'Farm',
        targetId: farm.farmId,
        details: 'Updated farm details for ${farm.farmName}',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error updating farm', e);
      return false;
    }
  }
}