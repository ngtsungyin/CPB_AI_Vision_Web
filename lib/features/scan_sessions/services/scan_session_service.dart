import 'package:supabase_flutter/supabase_flutter.dart';

class ScanSessionService {
  ScanSessionService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchScanSessions() async {
    final response = await _client
        .from('scan_sessions')
        .select('''
      *,
      farmer:users!scan_sessions_farmerid_fkey(
        firstname,
        lastname,
        email
      ),
      farm:farms!scan_sessions_farmid_fkey(
        farmname,
        state,
        district,
        village,
        latitude,
        longitude
      )
    ''')
        .order('sessiondate', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchScansBySession(
    String sessionId,
  ) async {
    final response = await _client
        .from('scans')
        .select('''
      scanid,
      farmerid,
      farmid,
      sessionid,
      eggsdetected,
      confidencescore,
      scandate,
      gpslocation,
      podindex,
      imageurl,
      imagepath,
      scan_images (
  imageid,
  imageurl,
  imagepath,
  imageindex,
  podindex,
  boxes,
  createdat
)
    ''')
        .eq('sessionid', sessionId)
        .order('scandate', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
