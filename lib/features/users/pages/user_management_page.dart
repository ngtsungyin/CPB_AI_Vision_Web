import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';
import 'package:cpbaivision_app/features/users/helpers/user_management_helper.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/user_page_header.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/user_filters_section.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/user_table_section.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/user_details_dialog.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/user_edit_dialog.dart';
import 'package:cpbaivision_app/features/users/widgets/user_management/delete_user_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _headerSearchController = TextEditingController();

  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = true;

  String _searchQuery = '';
  UserRole? _selectedRole;
  AccountStatus? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
    _headerSearchController.addListener(_onHeaderSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerSearchController.dispose();
    super.dispose();
  }

  void _onHeaderSearchChanged() {
    debugPrint('Header search: ${_headerSearchController.text}');
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _databaseService.getAllUsers();
      if (!mounted) return;

      setState(() {
        _users = users;
        _filteredUsers = applyUserFilters(
          users: users,
          searchQuery: _searchQuery,
          selectedRole: _selectedRole,
          selectedStatus: _selectedStatus,
          selectedDate: _selectedDate,
        );
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to load users: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredUsers = applyUserFilters(
        users: _users,
        searchQuery: _searchQuery,
        selectedRole: _selectedRole,
        selectedStatus: _selectedStatus,
        selectedDate: _selectedDate,
      );
    });
  }

  void _refreshFilters() {
    setState(() {
      _filteredUsers = applyUserFilters(
        users: _users,
        searchQuery: _searchQuery,
        selectedRole: _selectedRole,
        selectedStatus: _selectedStatus,
        selectedDate: _selectedDate,
      );
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateUserStatus(AppUser user, AccountStatus newStatus) async {
    try {
      await _databaseService.updateUserStatus(user.userId, newStatus.name);
      _showSuccessSnackbar('User status updated successfully');
      await _loadUsers();
    } catch (e) {
      _showErrorSnackbar('Failed to update user status: $e');
    }
  }

  Future<void> _updateUserRole(AppUser user, UserRole newRole) async {
    try {
      await _databaseService.updateUserRole(user.userId, newRole.name);
      _showSuccessSnackbar('User role updated successfully');
      await _loadUsers();
    } catch (e) {
      _showErrorSnackbar('Failed to update user role: $e');
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDeleteUserDialog(
      context: context,
      user: user,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _databaseService.deleteUser(user.userId);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('User deleted successfully');
      await _loadUsers();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to delete user.');
    }
  }

  Future<void> _showUserDetails(AppUser user) async {
    try {
      final farms = await _databaseService.getUserFarms(user.userId);
      if (!mounted) return;

      await showUserDetailsDialog(
        context: context,
        user: user,
        farms: farms,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to load user details: $e');
    }
  }

  Future<void> _showEditDialog(AppUser user) async {
    await showUserEditDialog(
      context: context,
      user: user,
      onSave: (status) async {
        if (status.name != user.accountStatus) {
          await _updateUserStatus(user, status);
        }
      },
    );
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRole = value != null
          ? UserRole.values.firstWhere((e) => e.name == value)
          : null;
      _refreshFilters();
    });
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _selectedStatus = value != null
          ? AccountStatus.values.firstWhere((e) => e.name == value)
          : null;
      _refreshFilters();
    });
  }

  void _onDateChanged(DateTime? value) {
    setState(() {
      _selectedDate = value;
      _refreshFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserPageHeader(),
          const SizedBox(height: 24),
          UserFiltersSection(
            searchController: _searchController,
            selectedRole: _selectedRole,
            selectedStatus: _selectedStatus,
            selectedDate: _selectedDate,
            onRoleChanged: _onRoleChanged,
            onStatusChanged: _onStatusChanged,
            onDateChanged: _onDateChanged,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: UserTableSection(
              isLoading: _isLoading,
              users: _filteredUsers,
              onView: _showUserDetails,
              onEdit: _showEditDialog,
              onDelete: _deleteUser,
            ),
          ),
        ],
      ),
    );
  }
}