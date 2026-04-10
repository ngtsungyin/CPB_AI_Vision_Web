class YieldRecord {
  final String recordId;
  final String farmerId;
  final String farmId;
  final DateTime harvestDate;
  final String beanType;
  final String beanGrade;
  final double quantityKg;
  final double? salesRevenue;
  final String? remarks;
  final DateTime createdAt;

  YieldRecord({
    required this.recordId,
    required this.farmerId,
    required this.farmId,
    required this.harvestDate,
    required this.beanType,
    required this.beanGrade,
    required this.quantityKg,
    this.salesRevenue,
    this.remarks,
    required this.createdAt,
  });

  factory YieldRecord.fromMap(Map<String, dynamic> map) {
    return YieldRecord(
      recordId: map['recordid']?.toString() ?? '',
      farmerId: map['farmerid']?.toString() ?? '',
      farmId: map['farmid']?.toString() ?? '',
      harvestDate: map['harvestdate'] != null
          ? DateTime.parse(map['harvestdate'].toString())
          : DateTime.now(),
      beanType: map['beantype']?.toString() ?? 'wet',
      beanGrade: map['beangrade']?.toString() ?? 'A',
      quantityKg: (map['quantitykg'] as num?)?.toDouble() ?? 0.0,
      salesRevenue: map['salesrevenue'] != null
          ? (map['salesrevenue'] as num).toDouble()
          : null,
      remarks: map['remarks']?.toString(),
      createdAt: map['createdat'] != null
          ? DateTime.parse(map['createdat'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordid': recordId,
      'farmerid': farmerId,
      'farmid': farmId,
      'harvestdate': harvestDate.toIso8601String(),
      'beantype': beanType,
      'beangrade': beanGrade,
      'quantitykg': quantityKg,
      'salesrevenue': salesRevenue,
      'remarks': remarks,
      'createdat': createdAt.toIso8601String(),
    };
  }
}