class LabourCost {
  final String labourId;
  final String farmerId;
  final String farmId;
  final double dailyLabourCost;
  final double farmAreaSprayPerDay;
  final double workCostPerDay;
  final double wetCocoaBeanPricePerKg;
  final int pesticideFrequencyPerYear;
  final double expectedYieldPerHectare;
  final DateTime createdAt;

  LabourCost({
    required this.labourId,
    required this.farmerId,
    required this.farmId,
    required this.dailyLabourCost,
    required this.farmAreaSprayPerDay,
    required this.workCostPerDay,
    required this.wetCocoaBeanPricePerKg,
    required this.pesticideFrequencyPerYear,
    required this.expectedYieldPerHectare,
    required this.createdAt,
  });

  factory LabourCost.fromMap(Map<String, dynamic> map) {
    return LabourCost(
      labourId: map['labourId'] as String,
      farmerId: map['farmerId'] as String,
      farmId: map['farmId'] as String,
      dailyLabourCost: (map['dailyLabourCost'] as num).toDouble(),
      farmAreaSprayPerDay: (map['farmAreaSprayPerDay'] as num).toDouble(),
      workCostPerDay: (map['workCostPerDay'] as num).toDouble(),
      wetCocoaBeanPricePerKg:
          (map['wetCocoaBeanPricePerKg'] as num).toDouble(),
      pesticideFrequencyPerYear: map['pesticideFrequencyPerYear'] as int,
      expectedYieldPerHectare:
          (map['expectedYieldPerHectare'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'labourId': labourId,
      'farmerId': farmerId,
      'farmId': farmId,
      'dailyLabourCost': dailyLabourCost,
      'farmAreaSprayPerDay': farmAreaSprayPerDay,
      'workCostPerDay': workCostPerDay,
      'wetCocoaBeanPricePerKg': wetCocoaBeanPricePerKg,
      'pesticideFrequencyPerYear': pesticideFrequencyPerYear,
      'expectedYieldPerHectare': expectedYieldPerHectare,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}