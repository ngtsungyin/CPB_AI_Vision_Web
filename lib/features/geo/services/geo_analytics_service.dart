import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class GeoAnalyticsService extends BaseSupabaseService {
  static const List<String> malaysiaStates = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Kuala Lumpur',
    'Putrajaya',
    'Labuan',
  ];

  Future<Map<String, Map<String, dynamic>>> getStateStatistics() async {
    final Map<String, Map<String, dynamic>> stats = {
      for (final state in malaysiaStates)
        state: {
          'farmers': 0,
          'scans': 0,
          'yield_revenue': 0.0,
        }
    };

    try {
      final farmsResponse = await client
          .from('farms')
          .select('farmid, ownerid, state');

      final scansResponse = await client
          .from('scans')
          .select('farmid');

      final yieldResponse = await client
          .from('yield_records')
          .select('farmid, salesrevenue');

      final farms = (farmsResponse as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final scans = (scansResponse as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final yields = (yieldResponse as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final Map<String, String> farmIdToState = {};
      final Map<String, Set<String>> stateToOwnerIds = {};

      for (final farm in farms) {
        final farmId = (farm['farmid'] ?? '').toString().toLowerCase();
        final ownerId = (farm['ownerid'] ?? '').toString().toLowerCase();
        final state = (farm['state'] ?? '').toString().trim();

        if (farmId.isEmpty || state.isEmpty) continue;

        farmIdToState[farmId] = state;
        stateToOwnerIds.putIfAbsent(state, () => <String>{});

        if (ownerId.isNotEmpty) {
          stateToOwnerIds[state]!.add(ownerId);
        }

        stats.putIfAbsent(state, () => {
              'farmers': 0,
              'scans': 0,
              'yield_revenue': 0.0,
            });
      }

      for (final entry in stateToOwnerIds.entries) {
        stats[entry.key]!['farmers'] = entry.value.length;
      }

      for (final scan in scans) {
        final farmId = (scan['farmid'] ?? '').toString().toLowerCase();
        if (farmId.isEmpty) continue;

        final state = farmIdToState[farmId];
        if (state == null) continue;

        stats[state]!['scans'] = (stats[state]!['scans'] as int) + 1;
      }

      for (final yieldRecord in yields) {
        final farmId = (yieldRecord['farmid'] ?? '').toString().toLowerCase();
        if (farmId.isEmpty) continue;

        final state = farmIdToState[farmId];
        if (state == null) continue;

        final revenueRaw = yieldRecord['salesrevenue'];
        final revenue =
            revenueRaw == null ? 0.0 : (revenueRaw as num).toDouble();

        stats[state]!['yield_revenue'] =
            (stats[state]!['yield_revenue'] as double) + revenue;
      }

      return stats;
    } catch (e) {
      logError('Error loading geo analytics', e);
      return stats;
    }
  }
}