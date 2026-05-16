// admin_audit_page.dart
import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';
import 'package:cpbaivision_app/features/admin/services/user_audit_log_service.dart';
import 'package:cpbaivision_app/features/admin/helpers/admin_audit_log_helper.dart';
import 'package:cpbaivision_app/features/admin/widgets/audits_page_header.dart';
import 'package:cpbaivision_app/features/admin/widgets/audits_search_section.dart';
import 'package:cpbaivision_app/features/admin/widgets/admin_audits_table_section.dart';
import 'package:cpbaivision_app/features/admin/widgets/user_audits_table_section.dart';

class AdminAuditPage extends StatefulWidget {
  const AdminAuditPage({super.key});

  @override
  State<AdminAuditPage> createState() => _AdminAuditPageState();
}

class _AdminAuditPageState extends State<AdminAuditPage> {
  final AdminAuditLogService _adminAuditLogService = AdminAuditLogService();
  final UserAuditLogService _userAuditLogService = UserAuditLogService();
  final TextEditingController _searchController = TextEditingController();

  // State for Admin Logs
  List<AdminAuditLog> _adminLogs = [];
  List<AdminAuditLog> _filteredAdminLogs = [];

  // State for User Logs
  List<UserAuditLog> _userLogs = [];
  List<UserAuditLog> _filteredUserLogs = [];

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllLogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Fetch both sets of logs in parallel
      final results = await Future.wait([
        _adminAuditLogService.getAllAuditLogs(),
        _userAuditLogService.getAllUserAuditLogs(),
      ]);

      if (!mounted) return;

      setState(() {
        _adminLogs = results[0] as List<AdminAuditLog>;
        _userLogs = results[1] as List<UserAuditLog>;

        _filteredAdminLogs = applyAuditLogFilters(
          logs: _adminLogs,
          searchQuery: _searchQuery,
        );
        _filteredUserLogs = applyUserAuditLogFilters(
          logs: _userLogs,
          searchQuery: _searchQuery,
        );
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to load audit logs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;

      _filteredAdminLogs = applyAuditLogFilters(
        logs: _adminLogs,
        searchQuery: _searchQuery,
      );

      _filteredUserLogs = applyUserAuditLogFilters(
        logs: _userLogs,
        searchQuery: _searchQuery,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tabs: Admin & User
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const AuditPageHeader(),
            const SizedBox(height: 16),

            // Tab Bar
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Admin Activity'),
                Tab(text: 'User Activity'),
              ],
            ),
            const SizedBox(height: 24),

            // Shared Search Section (Filters whatever tab is active)
            AuditsSearchSection(controller: _searchController),
            const SizedBox(height: 24),

            // Tab Bar Views (The Tables)
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Admin Audits
                  AuditTableSection(
                    isLoading: _isLoading,
                    records: _filteredAdminLogs,
                  ),

                  // Tab 2: User Audits
                  UserAuditTableSection(
                    isLoading: _isLoading,
                    records: _filteredUserLogs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
