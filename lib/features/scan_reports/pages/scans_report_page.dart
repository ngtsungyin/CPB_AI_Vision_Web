import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/scan_report_helper.dart';
import '../services/scan_report_service.dart';

import '../widgets/scan_report_page_header.dart';
import '../widgets/scan_report_search_section.dart';
import '../widgets/scan_report_table_section.dart';
import '../widgets/scan_report_details_dialog.dart';
import '../widgets/scan_report_delete_dialog.dart';
import 'package:cpbaivision_app/core/helpers/admin_export_helper.dart';

class ScansReportPage extends StatefulWidget {
  const ScansReportPage({super.key});

  @override
  State<ScansReportPage> createState() => _ScansReportPageState();
}

class _ScansReportPageState extends State<ScansReportPage> {
  final service = ScanReportService(Supabase.instance.client);

  final searchController = TextEditingController();

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];

  bool isLoading = true;
  String selectedDecision = 'All';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    setState(() => isLoading = true);

    try {
      final result = await service.fetchScanReports();

      data = result;
      _applyFilters();
    } catch (e) {
      debugPrint('Failed to fetch scan reports: $e');

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

  List<String> get exportHeaders => [
    'Farmer',
    'Email',
    'Farm',
    'State',
    'District',
    'Village',
    'Total Samples',
    'Cumulative Eggs',
    'Final Decision',
    'Pesticide Type',
    'Pesticide Price',
    'Pesticide Rate',
    'Pesticide Cost',
    'Daily Labour Cost',
    'Farm Area Spray Per Day',
    'Wet Cocoa Bean Price Per KG',
    'Pesticide Frequency Per Year',
    'Expected Yield Per Hectare',
    'Created Date',
  ];

  List<List<dynamic>> get exportRows {
    return filtered.map((item) {
      return [
        getFarmerName(item),
        safeText(item['farmer']?['email']),
        getFarmName(item),
        safeText(item['farm']?['state']),
        safeText(item['farm']?['district']),
        safeText(item['farm']?['village']),
        safeText(item['totalsample']),
        safeText(item['cumulativeeggs']),
        safeText(item['finaldecision']),
        safeText(item['pesticidetype']),
        safeText(item['pesticideprice']),
        safeText(item['pesticiderate']),
        safeText(item['pesticidecost']),
        safeText(item['dailylabourcost']),
        safeText(item['farmareasprayperday']),
        safeText(item['wetcocoabeanpriceperkg']),
        safeText(item['pesticidefrequencyperyear']),
        safeText(item['expectedyieldperhectare']),
        formatScanReportDate(item['createdat']),
      ];
    }).toList();
  }

  Future<void> exportCsv() async {
    await AdminExportHelper.exportCsv(
      fileName: 'scan_report_records',
      headers: exportHeaders,
      rows: exportRows,
    );
  }

  Future<void> exportPdf() async {
    await AdminExportHelper.exportPdf(
      title: 'Scan Report Records',
      fileName: 'scan_report_records',
      headers: exportHeaders,
      rows: exportRows,
    );
  }

  List<String> get decisions {
    final values = <String>{
      'All',
      ...data.map((item) => safeText(item['finaldecision'])),
    }.toList();

    values.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      return a.compareTo(b);
    });

    return values;
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();

    final result = data.where((item) {
      final farmer = getFarmerName(item).toLowerCase();
      final farm = getFarmName(item).toLowerCase();
      final decision = safeText(item['finaldecision']);
      final state = safeText(item['farm']?['state']).toLowerCase();
      final district = safeText(item['farm']?['district']).toLowerCase();

      final matchesSearch =
          farmer.contains(query) ||
          farm.contains(query) ||
          decision.toLowerCase().contains(query) ||
          state.contains(query) ||
          district.contains(query);

      final matchesDecision =
          selectedDecision == 'All' || decision == selectedDecision;

      return matchesSearch && matchesDecision;
    }).toList();

    filtered = result;
  }

  void handleSearch(String value) {
    setState(_applyFilters);
  }

  void handleDecisionChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedDecision = value;
      _applyFilters();
    });
  }

  Future<void> handleDelete(Map<String, dynamic> item) async {
    final confirm = await showDeleteScanReportDialog(
      context: context,
      item: item,
    );

    if (confirm != true) return;

    try {
      await service.deleteScanReport(item['reportid'].toString());
      await fetch();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan report deleted successfully.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to delete scan report: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete scan report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionValues = decisions;
    if (!decisionValues.contains(selectedDecision)) {
      selectedDecision = 'All';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScanReportPageHeader(),
          const SizedBox(height: 24),
          ScanReportSearchSection(
            controller: searchController,
            selectedDecision: selectedDecision,
            decisions: decisionValues,
            onSearch: handleSearch,
            onDecisionChanged: handleDecisionChanged,
            onRefresh: fetch,
            onExportCsv: exportCsv,
            onExportPdf: exportPdf,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ScanReportTableSection(
              isLoading: isLoading,
              items: filtered,
              onView: (item) =>
                  showScanReportDetailsDialog(context: context, item: item),
              onDelete: handleDelete,
            ),
          ),
        ],
      ),
    );
  }
}
