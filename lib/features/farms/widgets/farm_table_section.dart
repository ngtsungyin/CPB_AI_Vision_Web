import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/farms/helpers/farm_management_helper.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';

class FarmTableSection extends StatelessWidget {
  final bool isLoading;
  final List<Farm> farms;
  final Map<String, AppUser?> farmOwners;
  final Function(Farm) onView;
  final Function(Farm) onEdit;
  final Function(Farm) onToggle;
  final Function(Farm) onDelete;

  const FarmTableSection({
    super.key,
    required this.isLoading,
    required this.farms,
    required this.farmOwners,
    required this.onView,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<Farm>(
      isLoading: isLoading,
      items: farms,
      rowsPerPage: 10,
      emptyMessage: 'No farms found',
      columns: [
        AdminTableColumn<Farm>(
          label: 'Farm Name & Owner',
          width: 260,
          flexGrow: 1.6,
          cellBuilder: (_, farm) {
            final owner = farmOwners[farm.farmId];
            final ownerName = owner != null
                ? '${owner.firstName} ${owner.lastName}'
                : 'Loading...';

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTableText(
                  farm.farmName,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                AdminTableText(
                  'Owner: $ownerName',
                  color: Colors.grey,
                  maxLines: 2,
                ),
              ],
            );
          },
        ),
        AdminTableColumn<Farm>(
          label: 'Location',
          width: 220,
          flexGrow: 1.3,
          cellBuilder: (_, farm) => AdminTableText(
            '${farm.village}, ${farm.district}',
          ),
        ),
        AdminTableColumn<Farm>(
          label: 'Area',
          width: 110,
          flexGrow: 0.7,
          cellBuilder: (_, farm) => AdminTableText(
            farm.areaHectares.toStringAsFixed(1),
          ),
        ),
        AdminTableColumn<Farm>(
          label: 'Trees',
          width: 100,
          flexGrow: 0.6,
          cellBuilder: (_, farm) => AdminTableText(
            farm.treeCount.toString(),
          ),
        ),
        AdminTableColumn<Farm>(
          label: 'Status',
          width: 120,
          flexGrow: 0.7,
          cellBuilder: (_, farm) => Text(
            farm.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: farm.isActive ? Colors.green : Colors.red,
            ),
          ),
        ),
        AdminTableColumn<Farm>(
          label: 'Created',
          width: 130,
          flexGrow: 0.7,
          cellBuilder: (_, farm) => AdminTableText(
            formatFarmDate(farm.createdAt),
          ),
        ),
        AdminTableColumn<Farm>(
          label: 'Actions',
          width: 210,
          flexGrow: 0,
          cellBuilder: (_, farm) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => onView(farm),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(farm),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(
                  farm.isActive ? Icons.toggle_on : Icons.toggle_off,
                  color: farm.isActive ? Colors.green : Colors.grey,
                ),
                onPressed: () => onToggle(farm),
                tooltip: farm.isActive ? 'Deactivate' : 'Activate',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(farm),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}