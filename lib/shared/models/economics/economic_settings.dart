class EconomicSettings {
  final String settingId;
  final double pesticideCostPerLiter;
  final double workCostPerDay;
  final double wetCocoaBeanPricePerKg;
  final double expectedYieldPerHectare;
  final double sprayThreshold;
  final double monitorThreshold;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  EconomicSettings({
    required this.settingId,
    required this.pesticideCostPerLiter,
    required this.workCostPerDay,
    required this.wetCocoaBeanPricePerKg,
    required this.expectedYieldPerHectare,
    required this.sprayThreshold,
    required this.monitorThreshold,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  factory EconomicSettings.fromMap(Map<String, dynamic> map) {
    return EconomicSettings(
      settingId: map['settingid'] as String,
      pesticideCostPerLiter: (map['pesticidecostperliter'] as num).toDouble(),
      workCostPerDay: (map['workcostperday'] as num).toDouble(),
      wetCocoaBeanPricePerKg:
          (map['wetcocoabeanpriceperkg'] as num).toDouble(),
      expectedYieldPerHectare:
          (map['expectedyieldperhectare'] as num).toDouble(),
      sprayThreshold: (map['spraythreshold'] as num).toDouble(),
      monitorThreshold: (map['monitorthreshold'] as num).toDouble(),
      effectiveFrom: DateTime.parse(map['effectivefrom'] as String),
      effectiveTo: DateTime.parse(map['effectiveto'] as String),
      isActive: map['isactive'] as bool,
      createdBy: map['createdby'] as String,
      createdAt: DateTime.parse(map['createdat'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settingid': settingId,
      'pesticidecostperliter': pesticideCostPerLiter,
      'workcostperday': workCostPerDay,
      'wetcocoabeanpriceperkg': wetCocoaBeanPricePerKg,
      'expectedyieldperhectare': expectedYieldPerHectare,
      'spraythreshold': sprayThreshold,
      'monitorthreshold': monitorThreshold,
      'effectivefrom': effectiveFrom.toIso8601String(),
      'effectiveto': effectiveTo.toIso8601String(),
      'isactive': isActive,
      'createdby': createdBy,
      'createdat': createdAt.toIso8601String(),
    };
  }
}