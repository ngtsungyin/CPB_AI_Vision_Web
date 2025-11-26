// pages/user_management_page.dart
import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';

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

  // Filter states
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
    // Global search functionality if needed
    print('Header search: ${_headerSearchController.text}');
  }

  Future<void> _loadUsers() async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _databaseService.getAllUsers();
      if (mounted) {
        // Check again before setState
        setState(() {
          _users = users;
          _filteredUsers = users;
        });
      }
    } catch (e) {
      if (mounted) {
        // Check before showing error
        _showErrorSnackbar('Failed to load users: $e');
      }
    } finally {
      if (mounted) {
        // Check before setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<AppUser> filtered = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                user.firstName.toLowerCase().contains(_searchQuery) ||
                user.lastName.toLowerCase().contains(_searchQuery) ||
                user.email.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    // Apply role filter
    if (_selectedRole != null) {
      filtered = filtered
          .where((user) => user.role == _selectedRole!.name)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((user) => user.accountStatus == _selectedStatus!.name)
          .toList();
    }

    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered
          .where(
            (user) =>
                user.createdAt.year == _selectedDate!.year &&
                user.createdAt.month == _selectedDate!.month &&
                user.createdAt.day == _selectedDate!.day,
          )
          .toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _updateUserStatus(AppUser user, AccountStatus newStatus) async {
    try {
      await _databaseService.updateUserStatus(user.userId, newStatus.name);
      _showSuccessSnackbar('User status updated successfully');
      _loadUsers(); // Refresh the list
    } catch (e) {
      _showErrorSnackbar('Failed to update user status: $e');
    }
  }

  Future<void> _updateUserRole(AppUser user, UserRole newRole) async {
    try {
      await _databaseService.updateUserRole(user.userId, newRole.name);
      _showSuccessSnackbar('User role updated successfully');
      _loadUsers(); // Refresh the list
    } catch (e) {
      _showErrorSnackbar('Failed to update user role: $e');
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteUser(user.userId);
        _showSuccessSnackbar('User deleted successfully');
        _loadUsers(); // Refresh the list
      } catch (e) {
        _showErrorSnackbar('Failed to delete user: $e');
      }
    }
  }

  void _showUserDetails(AppUser user) async {
    final farms = await _databaseService.getUserFarms(user.userId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user.firstName} ${user.lastName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              if (user.phoneNumber != null)
                _buildDetailRow('Phone', user.phoneNumber!),
              _buildDetailRow('Role', _getRoleDisplayName(user.role)),
              _buildDetailRow(
                'Status',
                _getStatusDisplayName(user.accountStatus),
              ),
              _buildDetailRow('Joined Date', _formatDate(user.createdAt)),
              if (user.lastLoginAt != null)
                _buildDetailRow('Last Login', _formatDate(user.lastLoginAt!)),
              _buildDetailRow('Farms Count', '${farms.length}'),
              const SizedBox(height: 16),
              if (farms.isNotEmpty) ...[
                const Text(
                  'Associated Farms:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...farms.map(
                  (farm) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${farm.farmName} - ${farm.village}, ${farm.district}',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'farmer':
        return 'Farmer';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending_verification':
        return 'Pending Verification';
      case 'pending_approved':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // CHANGE: Use Container instead of Scaffold
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header Section (only title & description - NO AdminHeader)
          _buildPageHeaderSection(),
          const SizedBox(height: 24),

          // Filters Section
          _buildFiltersSection(),
          const SizedBox(height: 24),

          // Table Section
          Expanded(child: _buildTableSection()),
        ],
      ),
    );
  }

  Widget _buildPageHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all users in one place. Control access, assign roles, and monitor activity across your platform.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
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

            // Filter Dropdowns in column for mobile
            Column(
              children: [
                // Role Filter
                DropdownButtonFormField<String?>(
                  value: _selectedRole?.name,
                  decoration: InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    ...UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role.name,
                        child: Text(role.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value != null
                          ? UserRole.values.firstWhere((e) => e.name == value)
                          : null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Status Filter
                DropdownButtonFormField<String?>(
                  value: _selectedStatus?.name,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...AccountStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status.name,
                        child: Text(status.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value != null
                          ? AccountStatus.values.firstWhere(
                              (e) => e.name == value,
                            )
                          : null;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Date Filter
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Filter by Join Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop layout (existing code)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
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

          // Filter Dropdowns in row for desktop
          Row(
            children: [
              // Role Filter
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedRole?.name,
                  decoration: InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    ...UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role.name,
                        child: Text(role.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value != null
                          ? UserRole.values.firstWhere((e) => e.name == value)
                          : null;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedStatus?.name,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...AccountStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status.name,
                        child: Text(status.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value != null
                          ? AccountStatus.values.firstWhere(
                              (e) => e.name == value,
                            )
                          : null;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Date Filter
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Filter by Join Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TableHeaderCell(text: 'Full Name')),
                Expanded(flex: 2, child: _TableHeaderCell(text: 'Email')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Status')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Role')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Joined Date')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Last Active')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Actions')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.white
                              : Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _TableCell(
                                text: '${user.firstName} ${user.lastName}',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TableCell(text: user.email),
                            ),
                            Expanded(
                              flex: 1,
                              child: _StatusCell(status: user.accountStatus),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: _getRoleDisplayName(user.role),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: _formatDate(user.createdAt),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: user.lastLoginAt != null
                                    ? _formatDate(user.lastLoginAt!)
                                    : 'Never',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _ActionCell(
                                onView: () => _showUserDetails(user),
                                onEdit: () => _showEditDialog(user),
                                onDelete: () => _deleteUser(user),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AppUser user) {
    UserRole currentRole = UserRole.values.firstWhere(
      (e) => e.name == user.role,
      orElse: () => UserRole.farmer,
    );

    AccountStatus currentStatus = AccountStatus.values.firstWhere(
      (e) => e.name == user.accountStatus,
      orElse: () => AccountStatus.pending_verification,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit User - ${user.firstName} ${user.lastName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Selection
                const Text(
                  'Role:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<UserRole>(
                  value: currentRole,
                  isExpanded: true,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null) {
                      setDialogState(() {
                        currentRole = newRole;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Status Selection
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<AccountStatus>(
                  value: currentStatus,
                  isExpanded: true,
                  items: AccountStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      setDialogState(() {
                        currentStatus = newStatus;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (currentRole.name != user.role) {
                    await _updateUserRole(user, currentRole);
                  }
                  if (currentStatus.name != user.accountStatus) {
                    await _updateUserStatus(user, currentStatus);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Custom Table Header Cell Widget
class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Custom Table Cell Widget
class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}

// Custom Status Cell Widget
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusText,
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

// Custom Action Cell Widget
class _ActionCell extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionCell({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: onView,
            tooltip: 'View Details',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
