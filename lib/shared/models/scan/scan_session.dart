class ScanSession {
  final String sessionId;
  final String farmerId;
  final String farmId;
  final List<String> samples;
  final int totalEggs;
  final double averageEggs;
  final int cumulativeEggs;
  final String finalDecision;
  final String? recommendationReason;
  final DateTime sessionDate;
  final bool completed;

  ScanSession({
    required this.sessionId,
    required this.farmerId,
    required this.farmId,
    required this.samples,
    required this.totalEggs,
    required this.averageEggs,
    required this.cumulativeEggs,
    required this.finalDecision,
    this.recommendationReason,
    required this.sessionDate,
    required this.completed,
  });

  factory ScanSession.fromMap(Map<String, dynamic> map) {
    return ScanSession(
      sessionId: map['sessionid']?.toString() ?? '',
      farmerId: map['farmerid']?.toString() ?? '',
      farmId: map['farmid']?.toString() ?? '',
      samples: List<String>.from(map['samples'] ?? []),
      totalEggs: (map['totaleggs'] as num?)?.toInt() ?? 0,
      averageEggs: (map['averageeggs'] as num?)?.toDouble() ?? 0.0,
      cumulativeEggs: (map['cumulativeeggs'] as num?)?.toInt() ?? 0,
      finalDecision: map['finaldecision']?.toString() ?? 'continue_sampling',
      recommendationReason: map['recommendationreason']?.toString(),
      sessionDate: map['sessiondate'] != null
          ? DateTime.parse(map['sessiondate'].toString())
          : DateTime.now(),
      completed: map['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionid': sessionId,
      'farmerid': farmerId,
      'farmid': farmId,
      'samples': samples,
      'totaleggs': totalEggs,
      'averageeggs': averageEggs,
      'cumulativeeggs': cumulativeEggs,
      'finaldecision': finalDecision,
      'recommendationreason': recommendationReason,
      'sessiondate': sessionDate.toIso8601String(),
      'completed': completed,
    };
  }
}