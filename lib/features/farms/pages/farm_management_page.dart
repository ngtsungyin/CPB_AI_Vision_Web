import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';
import 'package:cpbaivision_app/features/farms/helpers/farm_management_helper.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_page_header.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_search_section.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_table_section.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_details_dialog.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_edit_dialog.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_delete_dialog.dart';
import 'package:cpbaivision_app/features/farms/widgets/farm_status_dialog.dart';

class FarmManagementPage extends StatefulWidget {
  const FarmManagementPage({super.key});

  @override
  State<FarmManagementPage> createState() => _FarmManagementPageState();
}

class _FarmManagementPageState extends State<FarmManagementPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Farm> _farms = [];
  List<Farm> _filteredFarms = [];
  Map<String, AppUser?> _farmOwners = {};

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFarms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarms() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final farms = await _databaseService.getAllFarms();

      final owners = <String, AppUser?>{};
      for (final farm in farms) {
        owners[farm.farmId] = await _databaseService.getUserById(farm.ownerId);
      }

      if (!mounted) return;

      setState(() {
        _farms = farms;
        _farmOwners = owners;
        _filteredFarms = applyFarmFilters(
          farms: farms,
          farmOwners: owners,
          searchQuery: _searchQuery,
        );
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load farms: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredFarms = applyFarmFilters(
        farms: _farms,
        farmOwners: _farmOwners,
        searchQuery: _searchQuery,
      );
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFarmStatus(Farm farm) async {
    final confirmed = await showFarmStatusDialog(
      context: context,
      farm: farm,
      newStatus: !farm.isActive, // ✅ REQUIRED
    );

    if (confirmed != true) return;

    try {
      await _databaseService.updateFarmStatus(farm.farmId, !farm.isActive);
      _showSuccess(
        farm.isActive
            ? 'Farm deactivated successfully'
            : 'Farm activated successfully',
      );
      await _loadFarms();
    } catch (e) {
      _showError('Failed to update farm status: $e');
    }
  }

  Future<void> _deleteFarm(Farm farm) async {
    final confirmed = await showDeleteFarmDialog(
      context: context,
      farm: farm,
      owner: _farmOwners[farm.farmId],
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _databaseService.deleteFarm(farm.farmId);

    if (!mounted) return;

    if (success) {
      _showSuccess('Farm deleted successfully');
      await _loadFarms();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to delete farm.');
    }
  }

  Future<void> _showFarmDetails(Farm farm) async {
    try {
      final owner = _farmOwners[farm.farmId];
      final scans = await _databaseService.getFarmScans(farm.farmId);

      if (!mounted) return;

      await showFarmDetailsDialog(
        context: context,
        farm: farm,
        owner: owner,
        scans: scans,
      );
    } catch (e) {
      _showError('Failed to load farm details: $e');
    }
  }

  Future<void> _showEditDialog(Farm farm) async {
    await showFarmEditDialog(
      context: context,
      farm: farm,
      onSave: (updatedFarm) async {
        try {
          await _databaseService.updateFarm(updatedFarm);
          _showSuccess('Farm updated successfully');
          await _loadFarms();
        } catch (e) {
          _showError('Failed to update farm: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FarmPageHeader(),
          const SizedBox(height: 24),
          FarmSearchSection(controller: _searchController),
          const SizedBox(height: 24),
          Expanded(
            child: FarmTableSection(
              isLoading: _isLoading,
              farms: _filteredFarms,
              farmOwners: _farmOwners,
              onView: _showFarmDetails,
              onEdit: _showEditDialog,
              onToggle: _toggleFarmStatus,
              onDelete: _deleteFarm,
            ),
          ),
        ],
      ),
    );
  }
}