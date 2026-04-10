import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class ScanSessionService extends BaseSupabaseService {
  Future<List<ScanSession>> getAllScanSessions() async {
    try {
      final response = await client
          .from('scan_sessions')
          .select()
          .order('sessiondate', ascending: false);

      return (response as List<dynamic>)
          .map((e) => ScanSession.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all scan sessions', e);
      return [];
    }
  }
}