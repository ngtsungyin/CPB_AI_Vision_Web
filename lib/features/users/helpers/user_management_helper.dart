import 'package:cpbaivision_app/shared/models/database_models.dart';

String getRoleDisplayName(String role) {
  switch (role) {
    case 'farmer':
      return 'Farmer';
    case 'admin':
      return 'Admin';
    default:
      return role;
  }
}

String getStatusDisplayName(String status) {
  switch (status) {
    case 'pending_verification':
      return 'Pending Verification';
    case 'pending_approved':
      return 'Pending Approval';
    case 'approved':
      return 'Approved';
    default:
      return status;
  }
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

List<AppUser> applyUserFilters({
  required List<AppUser> users,
  required String searchQuery,
  required UserRole? selectedRole,
  required AccountStatus? selectedStatus,
  required DateTime? selectedDate,
}) {
  List<AppUser> filtered = users;

  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered = filtered.where((user) {
      return user.firstName.toLowerCase().contains(query) ||
          user.lastName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  if (selectedRole != null) {
    filtered =
        filtered.where((user) => user.role == selectedRole.name).toList();
  }

  if (selectedStatus != null) {
    filtered = filtered
        .where((user) => user.accountStatus == selectedStatus.name)
        .toList();
  }

  if (selectedDate != null) {
    filtered = filtered.where((user) {
      return user.createdAt.year == selectedDate.year &&
          user.createdAt.month == selectedDate.month &&
          user.createdAt.day == selectedDate.day;
    }).toList();
  }

  return filtered;
}