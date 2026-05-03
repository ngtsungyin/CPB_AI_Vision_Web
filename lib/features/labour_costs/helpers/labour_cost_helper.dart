import 'package:intl/intl.dart';

String formatLabourDate(dynamic value) {
  if (value == null) return '-';

  try {
    final date = DateTime.parse(value.toString()).toLocal();
    return DateFormat('dd MMM yyyy').format(date);
  } catch (_) {
    return value.toString();
  }
}

String formatRM(dynamic value) {
  if (value == null) return 'RM 0.00';

  final number = num.tryParse(value.toString()) ?? 0;
  return 'RM ${number.toStringAsFixed(2)}';
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