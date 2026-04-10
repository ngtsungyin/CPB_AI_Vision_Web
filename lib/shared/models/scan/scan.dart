import 'gps_location.dart';

class Scan {
  final String scanId;
  final String farmerId;
  final String farmId;
  final String imageUrl;
  final String imagePath;
  final int eggsDetected;
  final double confidenceScore;
  final DateTime scanDate;
  final GpsLocation? gpsLocation;

  Scan({
    required this.scanId,
    required this.farmerId,
    required this.farmId,
    required this.imageUrl,
    required this.imagePath,
    required this.eggsDetected,
    required this.confidenceScore,
    required this.scanDate,
    this.gpsLocation,
  });

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      scanId: map['scanid']?.toString() ?? '',
      farmerId: map['farmerid']?.toString() ?? '',
      farmId: map['farmid']?.toString() ?? '',
      imageUrl: map['imageurl']?.toString() ?? '',
      imagePath: map['imagepath']?.toString() ?? '',
      eggsDetected: (map['eggsdetected'] as num?)?.toInt() ?? 0,
      confidenceScore: (map['confidencescore'] as num?)?.toDouble() ?? 0.0,
      scanDate: map['scandate'] != null
          ? DateTime.parse(map['scandate'].toString())
          : DateTime.now(),
      gpsLocation: map['gpslocation'] != null
          ? GpsLocation.fromMap(
              Map<String, dynamic>.from(map['gpslocation'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scanid': scanId,
      'farmerid': farmerId,
      'farmid': farmId,
      'imageurl': imageUrl,
      'imagepath': imagePath,
      'eggsdetected': eggsDetected,
      'confidencescore': confidenceScore,
      'scandate': scanDate.toIso8601String(),
      'gpslocation': gpsLocation?.toMap(),
    };
  }
}