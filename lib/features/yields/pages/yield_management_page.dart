import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';
import 'package:cpbaivision_app/features/yields/helpers/yield_management_helper.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_page_header.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_statistics_section.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_search_section.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_table_section.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_record_details_dialog.dart';
import 'package:cpbaivision_app/features/yields/widgets/yield_delete_dialog.dart';

class YieldManagementPage extends StatefulWidget {
  const YieldManagementPage({super.key});

  @override
  State<YieldManagementPage> createState() => _YieldManagementPageState();
}

class _YieldManagementPageState extends State<YieldManagementPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<YieldRecord> _yieldRecords = [];
  List<YieldRecord> _filteredRecords = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadYieldRecords();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadYieldRecords() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _databaseService.getAllYieldRecords();
      if (!mounted) return;

      setState(() {
        _yieldRecords = records;
        _filteredRecords = applyYieldFilters(
          records: records,
          searchQuery: _searchQuery,
        );
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to load yield records: $e');
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
      _filteredRecords = applyYieldFilters(
        records: _yieldRecords,
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteRecord(YieldRecord record) async {
    final confirmed = await showDeleteYieldDialog(
      context: context,
      record: record,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _databaseService.deleteYieldRecord(record.recordId);

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Yield record deleted successfully');
      await _loadYieldRecords();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to delete yield record.');
    }
  }

  Future<void> _showRecordDetails(YieldRecord record) async {
    try {
      final farmer = await _databaseService.getUserById(record.farmerId);
      final farm = await _databaseService.getFarmById(record.farmId);

      if (!mounted) return;

      await showYieldRecordDetailsDialog(
        context: context,
        record: record,
        farmer: farmer,
        farm: farm,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to load record details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YieldPageHeader(),
          const SizedBox(height: 24),
          YieldStatisticsSection(records: _yieldRecords),
          const SizedBox(height: 24),
          YieldSearchSection(controller: _searchController),
          const SizedBox(height: 24),
          Expanded(
            child: YieldTableSection(
              isLoading: _isLoading,
              records: _filteredRecords,
              onView: _showRecordDetails,
              onDelete: _deleteRecord,
            ),
          ),
        ],
      ),
    );
  }
}