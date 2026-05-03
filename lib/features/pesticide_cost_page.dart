import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/core/widgets/admin_table.dart';

class PesticideCostPage extends StatefulWidget {
  const PesticideCostPage({super.key});

  @override
  State<PesticideCostPage> createState() => _PesticideCostPageState();
}

class _PesticideCostPageState extends State<PesticideCostPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  bool isLoading = true;
  String searchQuery = '';

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
      final response = await supabase.from('pesticide_costs').select('''
            *,
            farmer:users!pesticide_costs_farmerid_fkey(
              firstname,
              lastname,
              email
            ),
            farm:farms!pesticide_costs_farmid_fkey(
              farmname,
              state,
              district,
              village
            )
          ''').order('createdat', ascending: false);

      debugPrint('Pesticide costs count: ${response.length}');
      debugPrint('Pesticide costs data: $response');

      data = response;
      filteredData = response;
    } catch (e) {
      debugPrint('Error fetching pesticide costs: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pesticide costs: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();

      filteredData = data.where((item) {
        final farmer = _farmerName(item).toLowerCase();
        final farm = _farmName(item).toLowerCase();
        final brand = _safeText(item['pesticidebrand']).toLowerCase();

        return farmer.contains(searchQuery) ||
            farm.contains(searchQuery) ||
            brand.contains(searchQuery);
      }).toList();
    });
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Pesticide Cost Records',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 270,
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search farmer / farm / brand...',
                prefixIcon: const Icon(Icons.search),
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
        DataColumn(label: Text('Brand')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Spray Pumps')),
        DataColumn(label: Text('Rate')),
        DataColumn(label: Text('Total Cost')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Action')),
      ],
      rows: filteredData.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(_farmerName(item))),
            DataCell(Text(_farmName(item))),
            DataCell(Text(_safeText(item['pesticidebrand']))),
            DataCell(Text('RM ${_safeText(item['pesticideprice'])}')),
            DataCell(Text(_safeText(item['numspraypump']))),
            DataCell(Text(_safeText(item['pesticiderate']))),
            DataCell(Text('RM ${_safeText(item['pesticidecost'])}')),
            DataCell(Text(_safeDate(item['createdat']))),
            DataCell(
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
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
      builder: (_) => AlertDialog(
        title: const Text('Pesticide Cost Details'),
        content: SizedBox(
          width: 500,
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
                _sectionTitle('Pesticide Cost Information'),
                _detailRow(
                  'Pesticide Brand',
                  _safeText(item['pesticidebrand']),
                ),
                _detailRow(
                  'Pesticide Price',
                  'RM ${_safeText(item['pesticideprice'])}',
                ),
                _detailRow(
                  'Number of Spray Pumps',
                  _safeText(item['numspraypump']),
                ),
                _detailRow(
                  'Pesticide Rate',
                  _safeText(item['pesticiderate']),
                ),
                _detailRow(
                  'Total Pesticide Cost',
                  'RM ${_safeText(item['pesticidecost'])}',
                ),
                _detailRow('Created Date', _safeDate(item['createdat'])),
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
      ),
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