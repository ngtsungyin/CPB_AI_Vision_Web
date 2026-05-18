import 'package:supabase_flutter/supabase_flutter.dart';

class AiAnalyticsService {
  AiAnalyticsService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchAiAnalyticsData() async {
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
          farm:farms!scans_farmid_fkey(
            farmname,
            state,
            district,
            village
          ),
          farmer:users!scans_farmerid_fkey(
            firstname,
            lastname,
            email
          ),
          scan_images(
            imageid,
            imageurl,
            imagepath,
            podindex,
            imageindex,
            boxes,
            createdat
          )
        ''')
        .order('scandate', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}