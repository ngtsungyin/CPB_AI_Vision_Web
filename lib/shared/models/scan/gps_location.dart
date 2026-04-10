class GpsLocation {
  final double lat;
  final double lng;

  GpsLocation({
    required this.lat,
    required this.lng,
  });

  factory GpsLocation.fromMap(Map<String, dynamic> map) {
    return GpsLocation(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}