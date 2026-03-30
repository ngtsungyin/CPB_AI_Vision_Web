import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/users/helpers/user_management_helper.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';

class UserTableSection extends StatelessWidget {
  final bool isLoading;
  final List<AppUser> users;
  final ValueChanged<AppUser> onView;
  final ValueChanged<AppUser> onEdit;
  final ValueChanged<AppUser> onDelete;

  const UserTableSection({
    super.key,
    required this.isLoading,
    required this.users,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<AppUser>(
      isLoading: isLoading,
      items: users,
      rowsPerPage: 10,
      emptyMessage: 'No users found',
      columns: [
        AdminTableColumn<AppUser>(
          label: 'Full Name',
          width: 180,
          flexGrow: 1.35,
          cellBuilder: (_, user) => AdminTableText(
            '${user.firstName} ${user.lastName}',
            fontWeight: FontWeight.w600,
          ),
        ),
        AdminTableColumn<AppUser>(
          label: 'Email',
          width: 240,
          flexGrow: 1.65,
          cellBuilder: (_, user) => AdminTableText(user.email),
        ),
        AdminTableColumn<AppUser>(
          label: 'Status',
          width: 155,
          flexGrow: 0.9,
          cellBuilder: (_, user) => _StatusCell(status: user.accountStatus),
        ),
        AdminTableColumn<AppUser>(
          label: 'Role',
          width: 120,
          flexGrow: 0.7,
          cellBuilder: (_, user) => AdminTableText(
            getRoleDisplayName(user.role),
          ),
        ),
        AdminTableColumn<AppUser>(
          label: 'Joined Date',
          width: 130,
          flexGrow: 0.75,
          cellBuilder: (_, user) => AdminTableText(
            formatDate(user.createdAt),
          ),
        ),
        AdminTableColumn<AppUser>(
          label: 'Last Active',
          width: 130,
          flexGrow: 0.75,
          cellBuilder: (_, user) => AdminTableText(
            user.lastLoginAt != null ? formatDate(user.lastLoginAt!) : 'Never',
          ),
        ),
        AdminTableColumn<AppUser>(
          label: 'Actions',
          width: 140,
          flexGrow: 0,
          cellBuilder: (_, user) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => onView(user),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(user),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(user),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;

  const _StatusCell({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        statusText = 'Approved';
        break;
      case 'pending_approved':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        statusText = 'Pending Approval';
        break;
      case 'pending_verification':
      default:
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[800]!;
        statusText = 'Pending Verification';
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
