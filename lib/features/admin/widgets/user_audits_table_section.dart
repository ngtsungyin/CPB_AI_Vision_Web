// user_audits_table_section.dart
import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/admin/helpers/admin_audit_log_helper.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';

class UserAuditTableSection extends StatelessWidget {
  final bool isLoading;
  final List<UserAuditLog> records;

  const UserAuditTableSection({
    super.key,
    required this.isLoading,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<UserAuditLog>(
      isLoading: isLoading,
      items: records,
      rowsPerPage: 10,
      emptyMessage: 'No user audit logs found',
      columns: [
        AdminTableColumn<UserAuditLog>(
          label: 'Farmer Name',
          width: 160,
          flexGrow: 1.2,
          cellBuilder: (_, record) => AdminTableText(record.farmerName),
        ),
        AdminTableColumn<UserAuditLog>(
          label: 'Phone',
          width: 120,
          flexGrow: 1.0,
          cellBuilder: (_, record) => AdminTableText(record.phoneNumber),
        ),
        AdminTableColumn<UserAuditLog>(
          label: 'Action',
          width: 100,
          flexGrow: 0.8,
          cellBuilder: (_, record) =>
              AdminTableText(record.action.toUpperCase()),
        ),
        AdminTableColumn<UserAuditLog>(
          label: 'Entity Type',
          width: 140,
          flexGrow: 1.1,
          cellBuilder: (_, record) => AdminTableText(
            record.entityType.replaceAll('_', ' ').toUpperCase(),
          ),
        ),
        AdminTableColumn<UserAuditLog>(
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
