import 'package:cpbaivision_app/shared/models/database_models.dart';

/// Formats the log timestamp.
/// Added hours and minutes since exact time is usually important for audit logs.
String formatLogTime(DateTime date) {
  final String hour = date.hour.toString().padLeft(2, '0');
  final String minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month}/${date.year} $hour:$minute';
}

/// Filters the audit logs based on a search query.
/// Checks the admin email, action, target type, and details.
List<AdminAuditLog> applyAuditLogFilters({
  required List<AdminAuditLog> logs,
  required String searchQuery,
}) {
  if (searchQuery.isEmpty) return logs;

  final query = searchQuery.toLowerCase();

  return logs.where((log) {
    return log.adminEmail.toLowerCase().contains(query) ||
        log.action.toLowerCase().contains(query) ||
        (log.targetType?.toLowerCase().contains(query) ?? false) ||
        (log.details?.toLowerCase().contains(query) ?? false);
  }).toList();
}

/// Returns the total number of logs.
int calculateTotalLogs(List<AdminAuditLog> logs) {
  return logs.length;
}

/// Filters the logs to show only those performed by a specific admin.
List<AdminAuditLog> filterLogsByAdmin(
  List<AdminAuditLog> logs,
  String adminEmail,
) {
  return logs.where((log) => log.adminEmail == adminEmail).toList();
}

/// Sorts the logs chronologically from newest to oldest and returns a specific count.
List<AdminAuditLog> getRecentLogs(List<AdminAuditLog> logs, {int limit = 20}) {
  final sortedLogs = List<AdminAuditLog>.from(logs)
    ..sort((a, b) => b.logTime.compareTo(a.logTime));

  if (sortedLogs.length <= limit) return sortedLogs;
  return sortedLogs.sublist(0, limit);
}

/// Filters the user audit logs based on a search query.
List<UserAuditLog> applyUserAuditLogFilters({
  required List<UserAuditLog> logs,
  required String searchQuery,
}) {
  if (searchQuery.isEmpty) return logs;

  final query = searchQuery.toLowerCase();

  return logs.where((log) {
    return log.farmerName.toLowerCase().contains(query) ||
        log.phoneNumber.toLowerCase().contains(query) ||
        log.action.toLowerCase().contains(query) ||
        log.entityType.toLowerCase().contains(query);
  }).toList();
}
