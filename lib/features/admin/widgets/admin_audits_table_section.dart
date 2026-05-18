// audits_table_section.dart
import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/admin/helpers/admin_audit_log_helper.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';

class AuditTableSection extends StatelessWidget {
  final bool isLoading;
  final List<AdminAuditLog> records;

  const AuditTableSection({
    super.key,
    required this.isLoading,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<AdminAuditLog>(
      isLoading: isLoading,
      items: records,
      rowsPerPage: 10,
      emptyMessage: 'No admin audit logs found',
      columns: [
        AdminTableColumn<AdminAuditLog>(
          label: 'Admin User',
          width: 180,
          flexGrow: 1.2,
          cellBuilder: (_, record) => AdminTableText(record.adminEmail),
        ),
        AdminTableColumn<AdminAuditLog>(
          label: 'Action',
          width: 100,
          flexGrow: 0.8,
          cellBuilder: (_, record) =>
              AdminTableText(record.action.toUpperCase()),
        ),
        AdminTableColumn<AdminAuditLog>(
          label: 'Target Type',
          width: 120,
          flexGrow: 1.0,
          cellBuilder: (_, record) => AdminTableText(record.targetType ?? '-'),
        ),
        // TARGET ID REMOVED HERE
        AdminTableColumn<AdminAuditLog>(
          label: 'Details',
          width: 280,
          flexGrow: 2.2, // Increased flex slightly since we removed a column
          cellBuilder: (_, record) => AdminTableText(record.details ?? '-'),
        ),
        AdminTableColumn<AdminAuditLog>(
          label: 'Log Time',
          width: 140,
          flexGrow: 1.1,
          cellBuilder: (_, record) =>
              AdminTableText(formatLogTime(record.logTime)),
        ),
      ],
    );
  }
}
