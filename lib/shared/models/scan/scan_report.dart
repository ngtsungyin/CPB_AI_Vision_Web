class ScanReport {
  final String reportId;
  final String sessionId;
  final String farmerId;
  final String farmId;
  final String? pesticideType;
  final double? pesticideCost;
  final double? pesticidePrice;
  final double? pesticideRate;
  final double? dailyLabourCost;
  final double? farmAreaSprayPerDay;
  final double? wetCocoaBeanPricePerKg;
  final int? pesticideFrequencyPerYear;
  final double? expectedYieldPerHectare;
  final int? totalSample;
  final int? cumulativeEggs;
  final String? finalDecision;
  final DateTime createdAt;

  ScanReport({
    required this.reportId,
    required this.sessionId,
    required this.farmerId,
    required this.farmId,
    this.pesticideType,
    this.pesticideCost,
    this.pesticidePrice,
    this.pesticideRate,
    this.dailyLabourCost,
    this.farmAreaSprayPerDay,
    this.wetCocoaBeanPricePerKg,
    this.pesticideFrequencyPerYear,
    this.expectedYieldPerHectare,
    this.totalSample,
    this.cumulativeEggs,
    this.finalDecision,
    required this.createdAt,
  });

  factory ScanReport.fromMap(Map<String, dynamic> map) {
    return ScanReport(
      reportId: map['reportId'] as String,
      sessionId: map['sessionId'] as String,
      farmerId: map['farmerId'] as String,
      farmId: map['farmId'] as String,
      pesticideType: map['pesticideType'] as String?,
      pesticideCost: map['pesticideCost'] != null
          ? (map['pesticideCost'] as num).toDouble()
          : null,
      pesticidePrice: map['pesticidePrice'] != null
          ? (map['pesticidePrice'] as num).toDouble()
          : null,
      pesticideRate: map['pesticideRate'] != null
          ? (map['pesticideRate'] as num).toDouble()
          : null,
      dailyLabourCost: map['dailyLabourCost'] != null
          ? (map['dailyLabourCost'] as num).toDouble()
          : null,
      farmAreaSprayPerDay: map['farmAreaSprayPerDay'] != null
          ? (map['farmAreaSprayPerDay'] as num).toDouble()
          : null,
      wetCocoaBeanPricePerKg: map['wetCocoaBeanPricePerKg'] != null
          ? (map['wetCocoaBeanPricePerKg'] as num).toDouble()
          : null,
      pesticideFrequencyPerYear: map['pesticideFrequencyPerYear'] as int?,
      expectedYieldPerHectare: map['expectedYieldPerHectare'] != null
          ? (map['expectedYieldPerHectare'] as num).toDouble()
          : null,
      totalSample: map['totalSample'] as int?,
      cumulativeEggs: map['cumulativeEggs'] as int?,
      finalDecision: map['finalDecision'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'sessionId': sessionId,
      'farmerId': farmerId,
      'farmId': farmId,
      'pesticideType': pesticideType,
      'pesticideCost': pesticideCost,
      'pesticidePrice': pesticidePrice,
      'pesticideRate': pesticideRate,
      'dailyLabourCost': dailyLabourCost,
      'farmAreaSprayPerDay': farmAreaSprayPerDay,
      'wetCocoaBeanPricePerKg': wetCocoaBeanPricePerKg,
      'pesticideFrequencyPerYear': pesticideFrequencyPerYear,
      'expectedYieldPerHectare': expectedYieldPerHectare,
      'totalSample': totalSample,
      'cumulativeEggs': cumulativeEggs,
      'finalDecision': finalDecision,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}