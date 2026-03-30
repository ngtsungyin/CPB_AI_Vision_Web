import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class DashboardService extends BaseSupabaseService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersResponse =
          await client.from('users').select().count(CountOption.exact);

      final farmsResponse =
          await client.from('farms').select().count(CountOption.exact);

      final scansResponse =
          await client.from('scans').select().count(CountOption.exact);

      final activeFarmsResponse = await client
          .from('farms')
          .select()
          .eq('isactive', true)
          .count(CountOption.exact);

      final pendingUsersResponse = await client
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
      logError('Error getting dashboard stats', e);
      return {
        'totalUsers': 0,
        'totalFarms': 0,
        'totalScans': 0,
        'activeFarms': 0,
        'pendingUsers': 0,
      };
    }
  }

  Future<Map<String, int>> getFarmCountByState() async {
    try {
      final response = await client
          .from('farms')
          .select('state');

      final Map<String, int> counts = {};

      for (final item in response as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final state = (map['state'] ?? '').toString().trim();

        if (state.isEmpty) continue;
        counts[state] = (counts[state] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      logError('Error getting farm count by state', e);
      return {};
    }
  }

  Future<Map<String, int>> getScanCountByState() async {
    try {
      final farmsResponse = await client
          .from('farms')
          .select('farmid, state');

      final Map<String, String> farmIdToState = {};

      for (final item in farmsResponse as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final farmId = (map['farmid'] ?? '').toString().trim().toLowerCase();
        final state = (map['state'] ?? '').toString().trim();

        if (farmId.isEmpty || state.isEmpty) continue;
        farmIdToState[farmId] = state;
      }

      final scansResponse = await client
          .from('scans')
          .select('scanid, farmid');

      final Map<String, int> counts = {};

      for (final item in scansResponse as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final farmId = (map['farmid'] ?? '').toString().trim().toLowerCase();

        if (farmId.isEmpty) continue;

        final state = farmIdToState[farmId];
        if (state == null || state.isEmpty) continue;

        counts[state] = (counts[state] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      logError('Error getting scan count by state', e);
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final response = await client
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
      logError('Error getting recent activity', e);
      return [];
    }
  }

  Future<bool> checkConnection() async {
    try {
      await client.from('users').select().limit(1);
      return true;
    } catch (e) {
      logError('Database connection error', e);
      return false;
    }
  }

  Future<Map<String, int>> getDecisionDistribution() async {
    try {
      final response = await client
          .from('scan_sessions')
          .select('finaldecision, completed')
          .eq('completed', true);

      int treat = 0;
      int continueSampling = 0;

      for (final item in response as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final decision = (map['finaldecision'] ?? '').toString().trim();

        if (decision == 'treat') {
          treat++;
        } else if (decision == 'continue_sampling') {
          continueSampling++;
        }
      }

      return {
        'treat': treat,
        'continue_sampling': continueSampling,
      };
    } catch (e) {
      logError('Error getting decision distribution', e);
      return {
        'treat': 0,
        'continue_sampling': 0,
      };
    }
  }

  Future<Map<String, List<int>>> getLast7DaysTrends() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = today.subtract(const Duration(days: 6));

      final scansResponse = await client
          .from('scans')
          .select('scandate')
          .gte('scandate', startDate.toIso8601String());

      final farmsResponse = await client
          .from('farms')
          .select('createdat')
          .gte('createdat', startDate.toIso8601String());

      final usersResponse = await client
          .from('users')
          .select('createdat')
          .gte('createdat', startDate.toIso8601String());

      final scanCounts = List<int>.filled(7, 0);
      final farmCounts = List<int>.filled(7, 0);
      final userCounts = List<int>.filled(7, 0);

      for (final item in scansResponse as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final rawDate = map['scandate'];
        final index = _getDayIndex(rawDate, startDate);
        if (index != null) scanCounts[index]++;
      }

      for (final item in farmsResponse as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final rawDate = map['createdat'];
        final index = _getDayIndex(rawDate, startDate);
        if (index != null) farmCounts[index]++;
      }

      for (final item in usersResponse as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final rawDate = map['createdat'];
        final index = _getDayIndex(rawDate, startDate);
        if (index != null) userCounts[index]++;
      }

      return {
        'scans': scanCounts,
        'farms': farmCounts,
        'users': userCounts,
      };
    } catch (e) {
      logError('Error getting last 7 days trends', e);
      return {
        'scans': List<int>.filled(7, 0),
        'farms': List<int>.filled(7, 0),
        'users': List<int>.filled(7, 0),
      };
    }
  }

  int? _getDayIndex(dynamic rawDate, DateTime startDate) {
    if (rawDate == null) return null;

    try {
      final parsed = DateTime.parse(rawDate.toString()).toLocal();
      final normalized = DateTime(parsed.year, parsed.month, parsed.day);
      final difference = normalized.difference(startDate).inDays;

      if (difference < 0 || difference > 6) return null;
      return difference;
    } catch (_) {
      return null;
    }
  }
}