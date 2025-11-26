// pages/yield_management_page.dart
import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';

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
      if (mounted) {
        setState(() {
          _yieldRecords = records;
          _filteredRecords = records;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load yield records: $e');
      }
    } finally {
      if (mounted) {
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
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredRecords = _yieldRecords;
      });
      return;
    }

    final filtered = _yieldRecords.where((record) {
      return record.beanType.toLowerCase().contains(_searchQuery) ||
          record.beanGrade.toLowerCase().contains(_searchQuery);
    }).toList();

    setState(() {
      _filteredRecords = filtered;
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

  Future<void> _deleteRecord(YieldRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete this yield record (${record.beanType} - ${record.quantityKg}kg)? This action cannot be undone.',
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
        await _databaseService.deleteYieldRecord(record.recordId);
        _showSuccessSnackbar('Yield record deleted successfully');
        _loadYieldRecords(); // Refresh the list
      } catch (e) {
        _showErrorSnackbar('Failed to delete yield record: $e');
      }
    }
  }

  void _showRecordDetails(YieldRecord record) async {
    final farmer = await _databaseService.getUserById(record.farmerId);
    final farm = await _databaseService.getFarmById(record.farmId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yield Record Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Farmer',
                '${farmer?.firstName} ${farmer?.lastName}',
              ),
              _buildDetailRow('Farm', farm!.farmName),
              _buildDetailRow('Harvest Date', _formatDate(record.harvestDate)),
              _buildDetailRow('Bean Type', record.beanType),
              _buildDetailRow('Bean Grade', record.beanGrade),
              _buildDetailRow('Quantity', '${record.quantityKg} kg'),
              if (record.salesRevenue != null)
                _buildDetailRow(
                  'Revenue',
                  '\$${record.salesRevenue!.toStringAsFixed(2)}',
                ),
              if (record.remarks != null && record.remarks!.isNotEmpty)
                _buildDetailRow('Remarks', record.remarks!),
              _buildDetailRow('Recorded', _formatDate(record.createdAt)),
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

          // Statistics Overview
          _buildStatisticsSection(),
          const SizedBox(height: 24),

          // Search & Filters
          _buildSearchSection(),
          const SizedBox(height: 24),

          // Yield Records Table
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
          'Yield Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor and manage cocoa yield records. Track harvest quantities, bean grades, and revenue.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    final totalYield = _yieldRecords.fold<double>(
      0,
      (sum, record) => sum + record.quantityKg,
    );
    final totalRevenue = _yieldRecords.fold<double>(
      0,
      (sum, record) => sum + (record.salesRevenue ?? 0),
    );
    final averageYield = _yieldRecords.isNotEmpty
        ? totalYield / _yieldRecords.length
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildStatCard(
            'Total Yield',
            '${totalYield.toStringAsFixed(1)} kg',
            Icons.scale,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Total Revenue',
            '\$${totalRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Avg Yield',
            '${averageYield.toStringAsFixed(1)} kg',
            Icons.trending_up,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Records',
            _yieldRecords.length.toString(),
            Icons.list_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
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
          hintText: 'Search yield records by bean type or grade...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                Expanded(flex: 2, child: _TableHeaderCell(text: 'Bean Type')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Grade')),
                Expanded(
                  flex: 1,
                  child: _TableHeaderCell(text: 'Quantity (kg)'),
                ),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Revenue')),
                Expanded(
                  flex: 1,
                  child: _TableHeaderCell(text: 'Harvest Date'),
                ),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Recorded')),
                Expanded(flex: 1, child: _TableHeaderCell(text: 'Actions')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: _filteredRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No yield records found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
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
                              child: _TableCell(text: record.beanType),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(text: record.beanGrade),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: record.quantityKg.toStringAsFixed(1),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: record.salesRevenue != null
                                    ? '\$${record.salesRevenue!.toStringAsFixed(2)}'
                                    : '-',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: _formatDate(record.harvestDate),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _TableCell(
                                text: _formatDate(record.createdAt),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _YieldActionCell(
                                onView: () => _showRecordDetails(record),
                                onDelete: () => _deleteRecord(record),
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

// Yield Action Cell Widget
class _YieldActionCell extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _YieldActionCell({required this.onView, required this.onDelete});

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
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

// Reuse table components
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
