import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';
import 'package:cpbaivision_app/features/admin/helpers/admin_audit_log_helper.dart';
import 'package:cpbaivision_app/features/admin/widgets/audits_page_header.dart';
import 'package:cpbaivision_app/features/admin/widgets/audits_search_section.dart';
import 'package:cpbaivision_app/features/admin/widgets/audits_table_section.dart';

class AdminAuditPage extends StatefulWidget {
  const AdminAuditPage({super.key});

  @override
  State<AdminAuditPage> createState() => _AdminAuditPageState();
}

class _AdminAuditPageState extends State<AdminAuditPage> {
  final AdminAuditLogService _auditLogService = AdminAuditLogService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminAuditLog> _auditLogs = [];
  List<AdminAuditLog> _filteredLogs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditLogs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _auditLogService.getAllAuditLogs();

      if (!mounted) return;

      setState(() {
        _auditLogs = records;
        _filteredLogs = applyAuditLogFilters(
          logs: records,
          searchQuery: _searchQuery,
        );
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _auditLogs = [];
        _filteredLogs = [];
      });

      _showErrorSnackbar('Failed to load audit logs: $e');
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
      _filteredLogs = applyAuditLogFilters(
        logs: _auditLogs,
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuditPageHeader(),
          const SizedBox(height: 24),
          AuditsSearchSection(controller: _searchController),
          const SizedBox(height: 24),
          Expanded(
            child: AuditTableSection(
              isLoading: _isLoading,
              records: _filteredLogs,
            ),
          ),
        ],
      ),
    );
  }
}