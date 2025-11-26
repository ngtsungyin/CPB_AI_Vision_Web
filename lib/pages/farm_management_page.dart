// pages/farm_management_page.dart
import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';

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
  bool _isLoading = true;
  String _searchQuery = '';

  // Store owner information
  final Map<String, AppUser?> _farmOwners = {};

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

    setState(() {
      _isLoading = true;
    });

    try {
      final farms = await _databaseService.getAllFarms();
      if (mounted) {
        setState(() {
          _farms = farms;
          _filteredFarms = farms;
        });
        // Load owner information for all farms
        await _loadFarmOwners(farms);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load farms: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFarmOwners(List<Farm> farms) async {
    for (final farm in farms) {
      try {
        final owner = await _databaseService.getUserById(farm.ownerId);
        if (mounted) {
          setState(() {
            _farmOwners[farm.farmId] = owner;
          });
        }
      } catch (e) {
        print('Error loading owner for farm ${farm.farmId}: $e');
        if (mounted) {
          setState(() {
            _farmOwners[farm.farmId] = null;
          });
        }
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
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredFarms = _farms;
      });
      return;
    }

    final filtered = _farms.where((farm) {
      final owner = _farmOwners[farm.farmId];
      final ownerName = owner != null ? '${owner.firstName} ${owner.lastName}' : '';
      
      return farm.farmName.toLowerCase().contains(_searchQuery) ||
          farm.village.toLowerCase().contains(_searchQuery) ||
          farm.district.toLowerCase().contains(_searchQuery) ||
          farm.state.toLowerCase().contains(_searchQuery) ||
          ownerName.toLowerCase().contains(_searchQuery);
    }).toList();

    setState(() {
      _filteredFarms = filtered;
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

  Future<void> _toggleFarmStatus(Farm farm) async {
    try {
      await _databaseService.updateFarmStatus(farm.farmId, !farm.isActive);
      _showSuccessSnackbar('Farm status updated successfully');
      _loadFarms(); // Refresh the list
    } catch (e) {
      _showErrorSnackbar('Failed to update farm status: $e');
    }
  }

  Future<void> _deleteFarm(Farm farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${farm.farmName}? This action cannot be undone.',
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
        await _databaseService.deleteFarm(farm.farmId);
        _showSuccessSnackbar('Farm deleted successfully');
        _loadFarms(); // Refresh the list
      } catch (e) {
        _showErrorSnackbar('Failed to delete farm: $e');
      }
    }
  }

  void _showFarmDetails(Farm farm) async {
    final owner = _farmOwners[farm.farmId] ?? await _databaseService.getUserById(farm.ownerId);
    final scans = await _databaseService.getFarmScans(farm.farmId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Farm Details - ${farm.farmName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Farm Name', farm.farmName),
              _buildDetailRow('Owner', '${owner?.firstName ?? 'N/A'} ${owner?.lastName ?? 'N/A'}'),
              _buildDetailRow('Email', owner?.email ?? 'N/A'),
              _buildDetailRow('Location', '${farm.village}, ${farm.district}'),
              _buildDetailRow('State', farm.state),
              _buildDetailRow('Postcode', farm.postcode),
              _buildDetailRow('Area', '${farm.areaHectares} hectares'),
              _buildDetailRow('Tree Count', '${farm.treeCount} trees'),
              _buildDetailRow('Status', farm.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Created', _formatDate(farm.createdAt)),
              const SizedBox(height: 16),
              
              // Scan Statistics
              const Text(
                'Scan Statistics:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Total Scans', '${scans.length}'),
              if (scans.isNotEmpty) ...[
                _buildDetailRow(
                  'Last Scan', 
                  _formatDate(scans.last.scanDate)
                ),
                _buildDetailRow(
                  'Avg Eggs/Scan', 
                  '${_calculateAverageEggs(scans).toStringAsFixed(1)}'
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
            width: 120,
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

  double _calculateAverageEggs(List<Scan> scans) {
    if (scans.isEmpty) return 0;
    final totalEggs = scans.fold(0, (sum, scan) => sum + scan.eggsDetected);
    return totalEggs / scans.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          _buildPageHeaderSection(),
          const SizedBox(height: 24),

          // Search & Filters
          _buildSearchSection(),
          const SizedBox(height: 24),

          // Farms Table
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
          'Farm Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage all registered farms. View farm details, monitor activity, and manage farm status.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search farms by name, village, district, state, or owner name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
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
                Expanded(flex: 2, child: _TableHeaderCell(text: 'Farm Name & Owner')),
                Expanded(flex: 2, child: _TableHeaderCell(text: 'Location')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Area (Ha)')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Trees')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Status')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Created')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Actions')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: _filteredFarms.isEmpty
                ? const Center(
                    child: Text(
                      'No farms found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFarms.length,
                    itemBuilder: (context, index) {
                      final farm = _filteredFarms[index];
                      final owner = _farmOwners[farm.farmId];
                      final ownerName = owner != null ? '${owner.firstName} ${owner.lastName}' : 'Loading...';
                      
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
                            // Farm Name & Owner Column
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      farm.farmName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Owner: $ownerName',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TableCell(
                                text: '${farm.village}, ${farm.district}',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: farm.areaHectares.toStringAsFixed(1),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: farm.treeCount.toString(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _StatusCell(
                                isActive: farm.isActive,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: _formatDate(farm.createdAt),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _FarmActionCell(
                                onView: () => _showFarmDetails(farm),
                                onToggle: () => _toggleFarmStatus(farm),
                                onDelete: () => _deleteFarm(farm),
                                isActive: farm.isActive,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Farm Status Cell Widget
class _StatusCell extends StatelessWidget {
  final bool isActive;

  const _StatusCell({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green[50]! : Colors.red[50]!,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: isActive ? Colors.green[800]! : Colors.red[800]!,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// Farm Action Cell Widget
class _FarmActionCell extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool isActive;

  const _FarmActionCell({
    required this.onView,
    required this.onToggle,
    required this.onDelete,
    required this.isActive,
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
            icon: Icon(
              isActive ? Icons.toggle_on : Icons.toggle_off,
              color: isActive ? Colors.green : Colors.grey,
            ),
            onPressed: onToggle,
            tooltip: isActive ? 'Deactivate' : 'Activate',
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

// Reuse these from user_management_page.dart
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