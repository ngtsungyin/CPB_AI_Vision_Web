import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/core/widgets/admin_table.dart';

class ScansReportPage extends StatefulWidget {
  const ScansReportPage({super.key});

  @override
  State<ScansReportPage> createState() => _ScansReportPageState();
}

class _ScansReportPageState extends State<ScansReportPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  bool isLoading = true;
  String searchQuery = '';
  String selectedDecision = 'All';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  String _safeDate(dynamic value) {
    if (value == null) return '-';
    final text = value.toString();
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  String _farmerName(dynamic item) {
    final farmer = item['farmer'];
    if (farmer == null) return '-';

    final first = farmer['firstname'] ?? '';
    final last = farmer['lastname'] ?? '';
    final fullName = '$first $last'.trim();

    return fullName.isEmpty ? '-' : fullName;
  }

  String _farmName(dynamic item) {
    return item['farm']?['farmname']?.toString() ?? '-';
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase.from('scan_reports').select('''
            *,
            farmer:users!scan_reports_farmerid_fkey(
              firstname,
              lastname,
              email
            ),
            farm:farms!scan_reports_farmid_fkey(
              farmname,
              state,
              district,
              village
            )
          ''').order('createdat', ascending: false);

      debugPrint('Scan reports count: ${response.length}');
      debugPrint('Scan reports data: $response');

      data = response;
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching scan reports: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scan reports: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchQuery.toLowerCase();

    filteredData = data.where((item) {
      final farmer = _farmerName(item).toLowerCase();
      final farm = _farmName(item).toLowerCase();
      final decision = _safeText(item['finaldecision']);

      final matchesSearch = farmer.contains(query) ||
          farm.contains(query) ||
          decision.toLowerCase().contains(query);

      final matchesDecision =
          selectedDecision == 'All' || decision == selectedDecision;

      return matchesSearch && matchesDecision;
    }).toList();
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void onDecisionChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedDecision = value;
      _applyFilters();
    });
  }

  Color _decisionColor(String decision) {
    final normalized = decision.toLowerCase();

    if (normalized.contains('spray') || normalized.contains('high')) {
      return const Color(0xFFDC2626);
    }

    if (normalized.contains('monitor') || normalized.contains('medium')) {
      return const Color(0xFFD97706);
    }

    if (normalized.contains('safe') || normalized.contains('low')) {
      return const Color(0xFF059669);
    }

    return const Color(0xFF4B5563);
  }

  Widget _decisionBadge(dynamic value) {
    final decision = _safeText(value);
    final color = _decisionColor(decision);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        decision,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildHeader() {
    final decisions = <String>{
      'All',
      ...data.map((item) => _safeText(item['finaldecision'])),
    }.toList();

    if (!decisions.contains(selectedDecision)) {
      selectedDecision = 'All';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Scans Report Records',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 270,
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search farmer / farm / decision...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<String>(
              value: selectedDecision,
              items: decisions.map((decision) {
                return DropdownMenuItem<String>(
                  value: decision,
                  child: Text(
                    decision,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onDecisionChanged,
              decoration: InputDecoration(
                labelText: 'Decision',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: fetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget buildTable() {
    return AdminTable(
      isLoading: isLoading,
      columns: const [
        DataColumn(label: Text('Farmer')),
        DataColumn(label: Text('Farm')),
        DataColumn(label: Text('Samples')),
        DataColumn(label: Text('Eggs')),
        DataColumn(label: Text('Decision')),
        DataColumn(label: Text('Pesticide Cost')),
        DataColumn(label: Text('Labour Cost')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Action')),
      ],
      rows: filteredData.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(_farmerName(item))),
            DataCell(Text(_farmName(item))),
            DataCell(Text(_safeText(item['totalsample']))),
            DataCell(Text(_safeText(item['cumulativeeggs']))),
            DataCell(_decisionBadge(item['finaldecision'])),
            DataCell(Text('RM ${_safeText(item['pesticidecost'])}')),
            DataCell(Text('RM ${_safeText(item['dailylabourcost'])}')),
            DataCell(Text(_safeDate(item['createdat']))),
            DataCell(
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View report details',
                onPressed: () => showDetails(item),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void showDetails(dynamic item) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Scan Report Details'),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Farmer & Farm'),
                  _detailRow('Farmer', _farmerName(item)),
                  _detailRow('Email', _safeText(item['farmer']?['email'])),
                  _detailRow('Farm', _farmName(item)),
                  _detailRow('State', _safeText(item['farm']?['state'])),
                  _detailRow('District', _safeText(item['farm']?['district'])),
                  _detailRow('Village', _safeText(item['farm']?['village'])),

                  const SizedBox(height: 16),
                  _sectionTitle('Scan Summary'),
                  _detailRow('Total Samples', _safeText(item['totalsample'])),
                  _detailRow(
                    'Cumulative Eggs',
                    _safeText(item['cumulativeeggs']),
                  ),
                  _detailRow(
                    'Final Decision',
                    _safeText(item['finaldecision']),
                  ),
                  _detailRow('Created Date', _safeDate(item['createdat'])),

                  const SizedBox(height: 16),
                  _sectionTitle('Pesticide Information'),
                  _detailRow(
                    'Pesticide Type',
                    _safeText(item['pesticidetype']),
                  ),
                  _detailRow(
                    'Pesticide Price',
                    'RM ${_safeText(item['pesticideprice'])}',
                  ),
                  _detailRow(
                    'Pesticide Rate',
                    _safeText(item['pesticiderate']),
                  ),
                  _detailRow(
                    'Pesticide Cost',
                    'RM ${_safeText(item['pesticidecost'])}',
                  ),
                  _detailRow(
                    'Frequency / Year',
                    _safeText(item['pesticidefrequencyperyear']),
                  ),

                  const SizedBox(height: 16),
                  _sectionTitle('Labour & Yield Information'),
                  _detailRow(
                    'Daily Labour Cost',
                    'RM ${_safeText(item['dailylabourcost'])}',
                  ),
                  _detailRow(
                    'Farm Area Spray / Day',
                    _safeText(item['farmareasprayperday']),
                  ),
                  _detailRow(
                    'Wet Cocoa Bean Price / KG',
                    'RM ${_safeText(item['wetcocoabeanpriceperkg'])}',
                  ),
                  _detailRow(
                    'Expected Yield / Hectare',
                    _safeText(item['expectedyieldperhectare']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        buildTable(),
      ],
    );
  }
}