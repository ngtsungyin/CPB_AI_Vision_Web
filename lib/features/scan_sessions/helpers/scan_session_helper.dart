import 'package:intl/intl.dart';

String formatScanSessionDate(dynamic value) {
  if (value == null) return '-';

  try {
    final date = DateTime.parse(value.toString()).toLocal();
    return DateFormat('dd MMM yyyy').format(date);
  } catch (_) {
    return value.toString();
  }
}

String safeText(dynamic value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

String getFarmerName(Map<String, dynamic> item) {
  final farmer = item['farmer'];
  if (farmer == null) return '-';

  final first = farmer['firstname'] ?? '';
  final last = farmer['lastname'] ?? '';
  final name = '$first $last'.trim();

  return name.isEmpty ? '-' : name;
}

String getFarmName(Map<String, dynamic> item) {
  return item['farm']?['farmname']?.toString() ?? '-';
}

String formatGps(dynamic gps) {
  if (gps == null) return 'No GPS data available.';

  if (gps is Map) {
    final lat = gps['latitude'] ?? gps['lat'];
    final lng = gps['longitude'] ?? gps['lng'] ?? gps['lon'];

    if (lat != null && lng != null) {
      return '$lat, $lng';
    }

    return gps.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  return gps.toString();
}