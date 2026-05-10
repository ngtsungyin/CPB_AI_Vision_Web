import 'package:supabase_flutter/supabase_flutter.dart';

class ScanReportService {
  ScanReportService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchScanReports() async {
    final response = await _client.from('scan_reports').select('''
      *,
      farmer:users!scan_reports_farmerid_fkey(
        firstname,
        lastname,
        email
      ),
      farm:farms!scan_reports_farmid_fkey(
        farmname,
        state,
        district,
        village
      )
    ''').order('createdat', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteScanReport(String reportId) async {
    await _client.from('scan_reports').delete().eq('reportid', reportId);
  }
}