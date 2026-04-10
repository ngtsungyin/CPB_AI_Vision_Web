class Farm {
  final String farmId;
  final String ownerId;
  final String farmName;
  final String state;
  final String district;
  final String village;
  final String postcode;
  final double areaHectares;
  final int treeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Farm({
    required this.farmId,
    required this.ownerId,
    required this.farmName,
    required this.state,
    required this.district,
    required this.village,
    required this.postcode,
    required this.areaHectares,
    required this.treeCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      farmId: map['farmid']?.toString() ?? '',
      ownerId: map['ownerid']?.toString() ?? '',
      farmName: map['farmname']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      village: map['village']?.toString() ?? '',
      postcode: map['postcode']?.toString() ?? '',
      areaHectares: (map['areahectares'] as num?)?.toDouble() ?? 0.0,
      treeCount: (map['treecount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdat'] != null
          ? DateTime.parse(map['createdat'].toString())
          : DateTime.now(),
      updatedAt: map['updatedat'] != null
          ? DateTime.parse(map['updatedat'].toString())
          : DateTime.now(),
      isActive: map['isactive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmid': farmId,
      'ownerid': ownerId,
      'farmname': farmName,
      'state': state,
      'district': district,
      'village': village,
      'postcode': postcode,
      'areahectares': areaHectares,
      'treecount': treeCount,
      'createdat': createdAt.toIso8601String(),
      'updatedat': updatedAt.toIso8601String(),
      'isactive': isActive,
    };
  }

  Farm copyWith({
    String? farmName,
    String? village,
    String? district,
    String? state,
    String? postcode,
    double? areaHectares,
    int? treeCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      farmId: farmId,
      ownerId: ownerId,
      farmName: farmName ?? this.farmName,
      state: state ?? this.state,
      district: district ?? this.district,
      village: village ?? this.village,
      postcode: postcode ?? this.postcode,
      areaHectares: areaHectares ?? this.areaHectares,
      treeCount: treeCount ?? this.treeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}