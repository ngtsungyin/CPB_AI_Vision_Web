import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/base_supabase_service.dart';

class YieldService extends BaseSupabaseService {
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

  Future<bool> deleteYieldRecord(String recordId) async {
    try {
      await client
          .from('yield_records')
          .delete()
          .eq('recordid', recordId.toLowerCase());
      return true;
    } catch (e) {
      logError('Error deleting yield record', e);
      return false;
    }
  }
}