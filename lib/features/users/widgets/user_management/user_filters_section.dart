import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/utils/responsive_utils.dart';
import 'package:cpbaivision_app/features/users/helpers/user_management_helper.dart';

class UserFiltersSection extends StatelessWidget {
  final TextEditingController searchController;
  final UserRole? selectedRole;
  final AccountStatus? selectedStatus;
  final DateTime? selectedDate;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const UserFiltersSection({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.selectedDate,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          isMobile ? _buildMobileFilters(context) : _buildDesktopFilters(context),
        ],
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        _buildRoleDropdown(),
        const SizedBox(height: 12),
        _buildStatusDropdown(),
        const SizedBox(height: 12),
        _buildDateField(context),
      ],
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildRoleDropdown()),
        const SizedBox(width: 16),
        Expanded(child: _buildStatusDropdown()),
        const SizedBox(width: 16),
        Expanded(child: _buildDateField(context)),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String?>(
      value: selectedRole?.name,
      decoration: InputDecoration(
        labelText: 'Filter by Role',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All Roles'),
        ),
        ...UserRole.values.map((role) {
          return DropdownMenuItem<String?>(
            value: role.name,
            child: Text(role.displayName),
          );
        }),
      ],
      onChanged: onRoleChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String?>(
      value: selectedStatus?.name,
      decoration: InputDecoration(
        labelText: 'Filter by Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All Status'),
        ),
        ...AccountStatus.values.map((status) {
          return DropdownMenuItem<String?>(
            value: status.name,
            child: Text(status.displayName),
          );
        }),
      ],
      onChanged: onStatusChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate != null ? formatDate(selectedDate!) : '',
      ),
      decoration: InputDecoration(
        labelText: 'Filter by Join Date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear date',
                onPressed: () => onDateChanged(null),
              ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onDateChanged(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}