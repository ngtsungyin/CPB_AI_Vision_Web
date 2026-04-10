class PesticideCost {
  final String costId;
  final String farmerId;
  final String farmId;
  final String pesticideBrand;
  final double pesticidePrice;
  final int numSprayPump;
  final double pesticideRate;
  final double pesticideCost;
  final DateTime createdAt;

  PesticideCost({
    required this.costId,
    required this.farmerId,
    required this.farmId,
    required this.pesticideBrand,
    required this.pesticidePrice,
    required this.numSprayPump,
    required this.pesticideRate,
    required this.pesticideCost,
    required this.createdAt,
  });

  factory PesticideCost.fromMap(Map<String, dynamic> map) {
    return PesticideCost(
      costId: map['costId'] as String,
      farmerId: map['farmerId'] as String,
      farmId: map['farmId'] as String,
      pesticideBrand: map['pesticideBrand'] as String,
      pesticidePrice: (map['pesticidePrice'] as num).toDouble(),
      numSprayPump: map['numSprayPump'] as int,
      pesticideRate: (map['pesticideRate'] as num).toDouble(),
      pesticideCost: (map['pesticideCost'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'costId': costId,
      'farmerId': farmerId,
      'farmId': farmId,
      'pesticideBrand': pesticideBrand,
      'pesticidePrice': pesticidePrice,
      'numSprayPump': numSprayPump,
      'pesticideRate': pesticideRate,
      'pesticideCost': pesticideCost,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}