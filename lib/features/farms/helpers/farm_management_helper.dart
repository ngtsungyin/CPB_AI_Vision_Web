import 'package:cpbaivision_app/shared/models/database_models.dart';

String formatFarmDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

double calculateAverageEggs(List<Scan> scans) {
  if (scans.isEmpty) return 0;
  final totalEggs = scans.fold(0, (sum, scan) => sum + scan.eggsDetected);
  return totalEggs / scans.length;
}

List<Farm> applyFarmFilters({
  required List<Farm> farms,
  required Map<String, AppUser?> farmOwners,
  required String searchQuery,
}) {
  if (searchQuery.isEmpty) return farms;

  final query = searchQuery.toLowerCase();

  return farms.where((farm) {
    final owner = farmOwners[farm.farmId];
    final ownerName =
        owner != null ? '${owner.firstName} ${owner.lastName}' : '';

    return farm.farmName.toLowerCase().contains(query) ||
        farm.village.toLowerCase().contains(query) ||
        farm.district.toLowerCase().contains(query) ||
        farm.state.toLowerCase().contains(query) ||
        ownerName.toLowerCase().contains(query);
  }).toList();
}