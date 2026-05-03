import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';
import '../helpers/pesticide_cost_helper.dart';

class PesticideCostTableSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> items;

  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const PesticideCostTableSection({
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
      emptyMessage: 'No pesticide cost records found',
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
          label: 'Brand',
          width: 160,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['pesticidebrand'])),
        ),
        AdminTableColumn(
          label: 'Price',
          width: 120,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['pesticideprice'])),
        ),
        AdminTableColumn(
          label: 'Pumps',
          width: 100,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['numspraypump'])),
        ),
        AdminTableColumn(
          label: 'Rate',
          width: 120,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['pesticiderate'])),
        ),
        AdminTableColumn(
          label: 'Total Cost',
          width: 140,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['pesticidecost'])),
        ),
        AdminTableColumn(
          label: 'Created',
          width: 130,
          cellBuilder: (_, item) =>
              AdminTableText(formatPesticideDate(item['createdat'])),
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