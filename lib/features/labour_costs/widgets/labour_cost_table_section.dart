import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';
import '../helpers/labour_cost_helper.dart';

class LabourCostTableSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> items;

  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const LabourCostTableSection({
    super.key,
    required this.isLoading,
    required this.items,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<Map<String, dynamic>>(
      isLoading: isLoading,
      items: items,
      rowsPerPage: 10,
      emptyMessage: 'No labour cost records found',
      columns: [
        AdminTableColumn(
          label: 'Farmer',
          width: 180,
          cellBuilder: (_, item) =>
              AdminTableText(getFarmerName(item)),
        ),
        AdminTableColumn(
          label: 'Farm',
          width: 160,
          cellBuilder: (_, item) =>
              AdminTableText(getFarmName(item)),
        ),
        AdminTableColumn(
          label: 'Daily Labour',
          width: 140,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['dailylabourcost'])),
        ),
        AdminTableColumn(
          label: 'Work Cost',
          width: 140,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['workcostperday'])),
        ),
        AdminTableColumn(
          label: 'Yield/Ha',
          width: 120,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['expectedyieldperhectare'])),
        ),
        AdminTableColumn(
          label: 'Created',
          width: 130,
          cellBuilder: (_, item) =>
              AdminTableText(formatLabourDate(item['createdat'])),
        ),
        AdminTableColumn(
          label: 'Actions',
          width: 140,
          cellBuilder: (_, item) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => onView(item),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(item),
              ),
            ],
          ),
        ),
      ],
    );
  }
}