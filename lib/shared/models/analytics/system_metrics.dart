class SystemMetrics {
  final String metricId;
  final DateTime date;
  final int totalUsers;
  final int activeUsers;
  final int totalScans;
  final Map<String, dynamic>? scansByRegion;
  final Map<String, dynamic>? decisions;
  final double? averageConfidence;
  final int? falsePositives;
  final int? falseNegatives;
  final DateTime createdAt;

  SystemMetrics({
    required this.metricId,
    required this.date,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalScans,
    this.scansByRegion,
    this.decisions,
    this.averageConfidence,
    this.falsePositives,
    this.falseNegatives,
    required this.createdAt,
  });

  factory SystemMetrics.fromMap(Map<String, dynamic> map) {
    return SystemMetrics(
      metricId: map['metricId'] as String,
      date: DateTime.parse(map['date'] as String),
      totalUsers: map['totalUsers'] as int,
      activeUsers: map['activeUsers'] as int,
      totalScans: map['totalScans'] as int,
      scansByRegion: map['scansByRegion'] != null
          ? Map<String, dynamic>.from(map['scansByRegion'] as Map)
          : null,
      decisions: map['decisions'] != null
          ? Map<String, dynamic>.from(map['decisions'] as Map)
          : null,
      averageConfidence: map['averageConfidence'] != null
          ? (map['averageConfidence'] as num).toDouble()
          : null,
      falsePositives: map['falsePositives'] as int?,
      falseNegatives: map['falseNegatives'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metricId': metricId,
      'date': date.toIso8601String(),
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalScans': totalScans,
      'scansByRegion': scansByRegion,
      'decisions': decisions,
      'averageConfidence': averageConfidence,
      'falsePositives': falsePositives,
      'falseNegatives': falseNegatives,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}