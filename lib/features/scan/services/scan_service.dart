import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class ScanService extends BaseSupabaseService {
  Future<bool> createScan(Map<String, dynamic> scanData) async {
    try {
      await client.from('scans').insert(scanData);
      return true;
    } catch (e) {
      logError('Error creating scan', e);
      return false;
    }
  }

  Future<List<Scan>> getFarmScans(String farmId) async {
    try {
      final response = await client
          .from('scans')
          .select()
          .eq('farmid', farmId)
          .order('scandate', ascending: false);

      return (response as List<dynamic>)
          .map((e) => Scan.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting farm scans', e);
      return [];
    }
  }

  Future<List<Scan>> getAllScans() async {
    try {
      final response =
          await client.from('scans').select().order('scandate', ascending: false);

      return (response as List<dynamic>)
          .map((e) => Scan.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logError('Error getting all scans', e);
      return [];
    }
  }
}