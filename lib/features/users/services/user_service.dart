import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class UserService extends BaseSupabaseService {
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

  Future<bool> updateUserStatus(String userId, String newStatus) async {
    try {
      await client.from('users').update({
        'accountstatus': newStatus,
        'updatedat': DateTime.now().toIso8601String(),
      }).eq('userid', userId.toLowerCase());

      return true;
    } catch (e) {
      logError('Error updating user status', e);
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await client.from('users').update({
        'role': newRole,
        'updatedat': DateTime.now().toIso8601String(),
      }).eq('userid', userId.toLowerCase());

      return true;
    } catch (e) {
      logError('Error updating user role', e);
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await client.from('users').delete().eq('userid', userId.toLowerCase());
      return true;
    } catch (e) {
      logError('Error deleting user', e);
      return false;
    }
  }
}