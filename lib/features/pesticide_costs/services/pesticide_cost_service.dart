import 'package:supabase_flutter/supabase_flutter.dart';

class PesticideCostService {
  PesticideCostService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchPesticideCosts() async {
    final response = await _client.from('pesticide_costs').select('''
      *,
      farmer:users!pesticide_costs_farmerid_fkey(
        firstname,
        lastname,
        email
      ),
      farm:farms!pesticide_costs_farmid_fkey(
        farmname,
        state,
        district,
        village
      )
    ''').order('createdat', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updatePesticideCost({
    required String costId,
    required String pesticideBrand,
    required num pesticidePrice,
    required int numSprayPump,
    required num pesticideRate,
    required num pesticideCost,
  }) async {
    await _client.from('pesticide_costs').update({
      'pesticidebrand': pesticideBrand,
      'pesticideprice': pesticidePrice,
      'numspraypump': numSprayPump,
      'pesticiderate': pesticideRate,
      'pesticidecost': pesticideCost,
    }).eq('costid', costId);
  }

  Future<void> deletePesticideCost(String costId) async {
    await _client.from('pesticide_costs').delete().eq('costid', costId);
  }
}