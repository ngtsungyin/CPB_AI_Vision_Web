import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database_models.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // User Operations
  Future<AppUser?> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('userid', userId.toLowerCase())
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('createdat', ascending: false);

      return (response as List<dynamic>).map((e) => AppUser.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<bool> createUser(AppUser user) async {
    try {
      await _client.from('users').insert(user.toMap());
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<bool> updateUserStatus(String userId, String newStatus) async {
    try {
      await _client
          .from('users')
          .update({
            'accountstatus': newStatus,
            'updatedat': DateTime.now().toIso8601String(),
          })
          .eq('userid', userId.toLowerCase());
      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _client
          .from('users')
          .update({
            'role': newRole,
            'updatedat': DateTime.now().toIso8601String(),
          })
          .eq('userid', userId.toLowerCase());
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _client.from('users').delete().eq('userid', userId.toLowerCase());
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Farm Operations
  Future<List<Farm>> getUserFarms(String userId) async {
    try {
      final response = await _client
          .from('farms')
          .select()
          .eq('ownerid', userId.toLowerCase());

      return (response as List<dynamic>).map((e) => Farm.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting farms: $e');
      return [];
    }
  }

  Future<bool> createFarm(Farm farm) async {
    try {
      await _client.from('farms').insert(farm.toMap());
      return true;
    } catch (e) {
      print('Error creating farm: $e');
      return false;
    }
  }

  Future<List<Farm>> getAllFarms() async {
    try {
      final response = await _client
          .from('farms')
          .select()
          .order('createdat', ascending: false);

      return (response as List<dynamic>).map((e) => Farm.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all farms: $e');
      return [];
    }
  }

  Future<Farm?> getFarmById(String farmId) async {
    try {
      final response = await _client
          .from('farms')
          .select()
          .eq('farmid', farmId.toLowerCase())
          .single();

      return Farm.fromMap(response);
    } catch (e) {
      print('Error getting farm by ID: $e');
      return null;
    }
  }

  Future<bool> updateFarmStatus(String farmId, bool isActive) async {
    try {
      await _client
          .from('farms')
          .update({
            'isactive': isActive,
            'updatedat': DateTime.now().toIso8601String(),
          })
          .eq('farmid', farmId.toLowerCase());
      return true;
    } catch (e) {
      print('Error updating farm status: $e');
      return false;
    }
  }

  Future<bool> deleteFarm(String farmId) async {
    try {
      await _client.from('farms').delete().eq('farmid', farmId.toLowerCase());
      return true;
    } catch (e) {
      print('Error deleting farm: $e');
      return false;
    }
  }

  // Scan Operations
  Future<bool> createScan(Map<String, dynamic> scanData) async {
    try {
      await _client.from('scans').insert(scanData);
      return true;
    } catch (e) {
      print('Error creating scan: $e');
      return false;
    }
  }

  Future<List<Scan>> getFarmScans(String farmId) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('farmid', farmId.toLowerCase())
          .order('scandate', ascending: false);

      return (response as List<dynamic>).map((e) => Scan.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting farm scans: $e');
      return [];
    }
  }

  Future<List<Scan>> getAllScans() async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .order('scandate', ascending: false);

      return (response as List<dynamic>).map((e) => Scan.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all scans: $e');
      return [];
    }
  }

  // Yield Management Methods
  Future<List<YieldRecord>> getAllYieldRecords() async {
    try {
      final response = await _client
          .from('yield_records')
          .select()
          .order('harvestdate', ascending: false);

      return (response as List<dynamic>).map((e) => YieldRecord.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all yield records: $e');
      return [];
    }
  }

  Future<bool> deleteYieldRecord(String recordId) async {
    try {
      await _client.from('yield_records').delete().eq('recordid', recordId.toLowerCase());
      return true;
    } catch (e) {
      print('Error deleting yield record: $e');
      return false;
    }
  }

  // User method for yield management
  Future<AppUser?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('userid', userId.toLowerCase())
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Scan Session Operations
  Future<List<ScanSession>> getAllScanSessions() async {
    try {
      final response = await _client
          .from('scan_sessions')
          .select()
          .order('sessiondate', ascending: false);

      return (response as List<dynamic>).map((e) => ScanSession.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all scan sessions: $e');
      return [];
    }
  }

  // Dashboard statistics methods
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total users count
      final usersResponse = await _client
          .from('users')
          .select()
          .count(CountOption.exact);

      // Get total farms count
      final farmsResponse = await _client
          .from('farms')
          .select()
          .count(CountOption.exact);

      // Get total scans count
      final scansResponse = await _client
          .from('scans')
          .select()
          .count(CountOption.exact);

      // Get active farms count
      final activeFarmsResponse = await _client
          .from('farms')
          .select()
          .eq('isactive', true)
          .count(CountOption.exact);

      // Get pending approval users count
      final pendingUsersResponse = await _client
          .from('users')
          .select()
          .eq('accountstatus', 'pending_approved')
          .count(CountOption.exact);

      return {
        'totalUsers': usersResponse.count ?? 0,
        'totalFarms': farmsResponse.count ?? 0,
        'totalScans': scansResponse.count ?? 0,
        'activeFarms': activeFarmsResponse.count ?? 0,
        'pendingUsers': pendingUsersResponse.count ?? 0,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'totalFarms': 0,
        'totalScans': 0,
        'activeFarms': 0,
        'pendingUsers': 0,
      };
    }
  }

  // Get recent activity for dashboard
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      // Get recent scans with user and farm info
      final response = await _client
          .from('scans')
          .select('''
          *,
          users:farmerid(firstname, lastname),
          farms:farmid(farmname)
        ''')
          .order('scandate', ascending: false)
          .limit(10);

      return (response as List<dynamic>).map((scan) {
        final scanMap = scan as Map<String, dynamic>;
        final userData = scanMap['users'] as Map<String, dynamic>?;
        final farmData = scanMap['farms'] as Map<String, dynamic>?;

        return {
          'scan': Scan.fromMap(scanMap),
          'userName': userData != null
              ? '${userData['firstname']} ${userData['lastname']}'
              : 'Unknown User',
          'farmName': farmData?['farmname'] ?? 'Unknown Farm',
        };
      }).toList();
    } catch (e) {
      print('Error getting recent activity: $e');
      return [];
    }
  }

  // Additional utility method to check connection
  Future<bool> checkConnection() async {
    try {
      await _client.from('users').select().limit(1);
      return true;
    } catch (e) {
      print('Database connection error: $e');
      return false;
    }
  }
}