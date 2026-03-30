import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/yields/helpers/yield_management_helper.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';

class YieldTableSection extends StatelessWidget {
  final bool isLoading;
  final List<YieldRecord> records;
  final Function(YieldRecord) onView;
  final Function(YieldRecord) onDelete;

  const YieldTableSection({
    super.key,
    required this.isLoading,
    required this.records,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<YieldRecord>(
      isLoading: isLoading,
      items: records,
      rowsPerPage: 10,
      emptyMessage: 'No yield records found',
      columns: [
        AdminTableColumn<YieldRecord>(
          label: 'Bean Type',
          width: 180,
          flexGrow: 1.4,
          cellBuilder: (_, record) => AdminTableText(record.beanType),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Grade',
          width: 110,
          flexGrow: 0.85,
          cellBuilder: (_, record) => AdminTableText(record.beanGrade),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Quantity (kg)',
          width: 130,
          flexGrow: 0.95,
          cellBuilder: (_, record) => AdminTableText(
            record.quantityKg.toStringAsFixed(1),
          ),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Revenue',
          width: 140,
          flexGrow: 1.0,
          cellBuilder: (_, record) => AdminTableText(
            record.salesRevenue != null
                ? 'RM ${record.salesRevenue!.toStringAsFixed(2)}'
                : '-',
          ),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Harvest Date',
          width: 135,
          flexGrow: 0.9,
          cellBuilder: (_, record) => AdminTableText(
            formatYieldDate(record.harvestDate),
          ),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Recorded',
          width: 135,
          flexGrow: 0.9,
          cellBuilder: (_, record) => AdminTableText(
            formatYieldDate(record.createdAt),
          ),
        ),
        AdminTableColumn<YieldRecord>(
          label: 'Actions',
          width: 120,
          flexGrow: 0,
          cellBuilder: (_, record) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => onView(record),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(record),
                tooltip: 'Delete Record',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
