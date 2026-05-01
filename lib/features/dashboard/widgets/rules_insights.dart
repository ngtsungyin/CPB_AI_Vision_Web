import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';
import 'package:cpbaivision_app/features/dashboard/services/dashboard_service.dart';
import 'package:cpbaivision_app/features/dashboard/services/insight_service.dart'; // Import the engine

class RulesInsightsCard extends StatefulWidget {
  const RulesInsightsCard({super.key});

  @override
  State<RulesInsightsCard> createState() => _RulesInsightsCardState();
}

class _RulesInsightsCardState extends State<RulesInsightsCard> {
  final DashboardService _dashboardService = DashboardService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  List<String> _insights = [];

  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  Future<void> _loadInsightsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all required data concurrently
      final results = await Future.wait([
        _dashboardService.getLast7DaysTrends(),
        _dashboardService.getDecisionDistribution(),
        _databaseService.getDashboardStats(),
      ]);

      final trendsData = results[0] as Map<String, dynamic>;
      final decisionData = results[1] as Map<String, dynamic>;
      final statsData = results[2] as Map<String, dynamic>;

      // Extract specific metrics
      final scanTrend = _safeIntList(trendsData['scans']);
      final treatCount = (decisionData['treat'] as num?)?.toInt() ?? 0;
      final continueSamplingCount =
          (decisionData['continue_sampling'] as num?)?.toInt() ?? 0;
      final pendingUsers = (statsData['pendingUsers'] as num?)?.toInt() ?? 0;

      // Run the rules engine
      final generatedInsights = InsightEngineService.generateInsights(
        scanTrend: scanTrend,
        treatCount: treatCount,
        continueSamplingCount: continueSamplingCount,
        pendingUsers: pendingUsers,
      );

      setState(() {
        _insights = generatedInsights;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _insights = ['❌ Unable to load insights at this time.'];
        _isLoading = false;
      });
    }
  }

  // Helper method copied from your AnalyticsChartCard
  List<int> _safeIntList(dynamic rawList) {
    if (rawList is! List) return List<int>.filled(7, 0);
    return List<int>.generate(7, (index) {
      if (index >= rawList.length) return 0;
      final value = rawList[index];
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white, // Matches your other cards
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade50.withOpacity(0.5),
              Colors.blueGrey.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Automated Operational Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._insights.map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              insight,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
