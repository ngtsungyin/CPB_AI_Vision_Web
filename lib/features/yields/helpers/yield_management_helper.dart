import 'package:cpbaivision_app/shared/models/database_models.dart';

String formatYieldDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

List<YieldRecord> applyYieldFilters({
  required List<YieldRecord> records,
  required String searchQuery,
}) {
  if (searchQuery.isEmpty) return records;

  final query = searchQuery.toLowerCase();

  return records.where((record) {
    return record.beanType.toLowerCase().contains(query) ||
        record.beanGrade.toLowerCase().contains(query);
  }).toList();
}

double calculateTotalYield(List<YieldRecord> records) {
  return records.fold<double>(
    0,
    (sum, record) => sum + record.quantityKg,
  );
}

double calculateTotalRevenue(List<YieldRecord> records) {
  return records.fold<double>(
    0,
    (sum, record) => sum + (record.salesRevenue ?? 0),
  );
}

double calculateAverageYield(List<YieldRecord> records) {
  if (records.isEmpty) return 0;
  return calculateTotalYield(records) / records.length;
}