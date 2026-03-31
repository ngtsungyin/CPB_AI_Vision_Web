import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';
import 'package:uuid/uuid.dart'; 

class UserService extends BaseSupabaseService {
  final AdminAuditLogService _auditLogService = AdminAuditLogService();
  final Uuid _uuid = const Uuid(); 

  // --- READ METHODS (No auditing needed) ---

  Future<AppUser?> getUser(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('userid', userId.toLowerCase())
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      logError('Error getting user', e);
      return null;
    }
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('userid', userId.toLowerCase())
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      logError('Error getting user by ID', e);
      return null;
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await client
          .from('users')
          .select()
          .order('createdat', ascending: false);

      return (response as List<dynamic>)
          .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all users', e);
      return [];
    }
  }
    Future<bool> createUser(AppUser user) async {
    try {
      await client.from('users').insert(user.toMap());
      return true;
    } catch (e) {
      logError('Error creating user', e);
      return false;
    }
  }

  // --- MUTATION METHODS (These get audited!) ---

  Future<bool> updateUserStatus(String userId, String newStatus, String adminEmail) async {
    try {
      await client.from('users').update({
        'accountstatus': newStatus,
        'updatedat': DateTime.now().toIso8601String(),
      }).eq('userid', userId.toLowerCase());

      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'UPDATE',
        targetType: 'User',
        targetId: userId,
        details: 'Changed user account status to: $newStatus',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error updating user status', e);
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole, String adminEmail) async {
    try {
      await client.from('users').update({
        'role': newRole,
        'updatedat': DateTime.now().toIso8601String(),
      }).eq('userid', userId.toLowerCase());

      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'UPDATE',
        targetType: 'User',
        targetId: userId,
        details: 'Changed user role to: $newRole',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error updating user role', e);
      return false;
    }
  }

  Future<bool> deleteUser(String userId, String adminEmail) async {
    try {
      await client.from('users').delete().eq('userid', userId.toLowerCase());
      
      // LOG THE AUDIT
      await _auditLogService.createAuditLog(AdminAuditLog(
        logId: _uuid.v4(),
        adminEmail: adminEmail,
        action: 'DELETE',
        targetType: 'User',
        targetId: userId,
        details: 'Deleted user account',
        logTime: DateTime.now(),
      ));

      return true;
    } catch (e) {
      logError('Error deleting user', e);
      return false;
    }
  }
}