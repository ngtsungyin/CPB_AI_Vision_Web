import 'package:supabase_flutter/supabase_flutter.dart';

class LabourCostService {
  LabourCostService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchLabourCosts() async {
    final response = await _client.from('labour_costs').select('''
      *,
      farmer:users!labour_costs_farmerid_fkey(
        firstname,
        lastname,
        email
      ),
      farm:farms!labour_costs_farmid_fkey(
        farmname,
        state,
        district,
        village
      )
    ''').order('createdat', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateLabourCost({
    required String labourId,
    required num dailyLabourCost,
    required num farmAreaSprayPerDay,
    required num workCostPerDay,
    required num wetCocoaBeanPricePerKg,
    required int pesticideFrequencyPerYear,
    required num expectedYieldPerHectare,
  }) async {
    await _client.from('labour_costs').update({
      'dailylabourcost': dailyLabourCost,
      'farmareasprayperday': farmAreaSprayPerDay,
      'workcostperday': workCostPerDay,
      'wetcocoabeanpriceperkg': wetCocoaBeanPricePerKg,
      'pesticidefrequencyperyear': pesticideFrequencyPerYear,
      'expectedyieldperhectare': expectedYieldPerHectare,
    }).eq('labourid', labourId);
  }

  Future<void> deleteLabourCost(String labourId) async {
    await _client.from('labour_costs').delete().eq('labourid', labourId);
  }
}