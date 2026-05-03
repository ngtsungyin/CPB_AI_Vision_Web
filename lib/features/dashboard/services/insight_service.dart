class InsightEngineService {
  /// Evaluates dashboard data and returns a list of actionable insights.
  static List<String> generateInsights({
    required List<int> scanTrend,
    required int treatCount,
    required int continueSamplingCount,
    required int pendingUsers,
  }) {
    List<String> insights = [];

    // Rule 1: Scan Volume Drop (Comparing today to the 6-day average)
    if (scanTrend.length == 7) {
      final todayScans = scanTrend.last;
      final previousScans = scanTrend.sublist(0, 6);
      final avgPrevious = previousScans.fold<int>(0, (a, b) => a + b) / 6.0;

      // If today's scans are more than 30% below the average
      if (avgPrevious > 0 && todayScans < (avgPrevious * 0.7)) {
        insights.add(
          '📉 Volume Alert: Today\'s scan activity is lower than the weekly average. Ensure farm agents are syncing their offline data.',
        );
      }
    }

    // Rule 2: Treatment Threshold
    final totalDecisions = treatCount + continueSamplingCount;
    if (totalDecisions > 0) {
      final treatPercentage = (treatCount / totalDecisions) * 100;
      // If more than 25% of decisions require treatment
      if (treatPercentage > 25.0) {
        insights.add(
          '⚠️ Health Alert: ${treatPercentage.toStringAsFixed(1)}% of recent scans resulted in a "Treat" decision. High rate of anomalies detected.',
        );
      }
    }

    // Rule 3: Administrative Action
    if (pendingUsers > 0) {
      insights.add(
        '👤 Admin Action: There are $pendingUsers pending users waiting for approval to access the system.',
      );
    }

    // Fallback if everything is running smoothly
    if (insights.isEmpty) {
      insights.add(
        '✅ Operations Normal: Scan volumes and sampling decisions are tracking within expected ranges.',
      );
    }

    return insights;
  }
}
