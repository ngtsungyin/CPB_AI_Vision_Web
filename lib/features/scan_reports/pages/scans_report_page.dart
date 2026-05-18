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

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScansReportPage extends StatefulWidget {
  const ScansReportPage({super.key});

  @override
  State<ScansReportPage> createState() => _ScansReportPageState();
}

class _ScansReportPageState extends State<ScansReportPage> {
  final service = ScanReportService(Supabase.instance.client);
  final searchController = TextEditingController();

  final Set<String> selectedReportIds = {};

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

  String _reportId(Map<String, dynamic> item) {
    return item['reportid']?.toString() ?? '';
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

  List<dynamic> exportRowFor(Map<String, dynamic> item) {
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
  }

  List<List<dynamic>> exportRowsFor(List<Map<String, dynamic>> items) {
    return items.map(exportRowFor).toList();
  }

  List<Map<String, dynamic>> get selectedReports {
    return filtered.where((item) {
      final id = _reportId(item);
      return selectedReportIds.contains(id);
    }).toList();
  }

  Future<void> exportSingleCsv(Map<String, dynamic> item) async {
    final id = _reportId(item);

    await AdminExportHelper.exportCsv(
      fileName: 'scan_report_$id',
      headers: exportHeaders,
      rows: [exportRowFor(item)],
    );
  }

  Future<void> exportSelectedCsv() async {
    final items = selectedReports;

    if (items.isEmpty) {
      _showSnackBar('Please select at least one scan report to export.');
      return;
    }

    await AdminExportHelper.exportCsv(
      fileName: 'selected_scan_reports',
      headers: exportHeaders,
      rows: exportRowsFor(items),
    );
  }

  Future<void> exportSinglePdf(Map<String, dynamic> item) async {
    final id = _reportId(item);

    await exportReportsAsSeparatedPdf(
      reports: [item],
      fileName: 'scan_report_$id.pdf',
    );
  }

  Future<void> exportSelectedPdf() async {
    final items = selectedReports;

    if (items.isEmpty) {
      _showSnackBar('Please select at least one scan report to export.');
      return;
    }

    await exportReportsAsSeparatedPdf(
      reports: items,
      fileName: 'selected_scan_reports.pdf',
    );
  }

  Future<void> exportReportsAsSeparatedPdf({
    required List<Map<String, dynamic>> reports,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    for (int index = 0; index < reports.length; index++) {
      final item = reports[index];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Scan Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated from CPB AI Vision Admin Dashboard',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'Report ${index + 1} of ${reports.length}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              _pdfSection(
                title: 'Farmer & Farm Information',
                rows: [
                  ['Farmer', getFarmerName(item)],
                  ['Email', safeText(item['farmer']?['email'])],
                  ['Farm', getFarmName(item)],
                  ['State', safeText(item['farm']?['state'])],
                  ['District', safeText(item['farm']?['district'])],
                  ['Village', safeText(item['farm']?['village'])],
                ],
              ),

              pw.SizedBox(height: 14),

              _pdfSection(
                title: 'Scan Summary',
                rows: [
                  ['Total Samples', safeText(item['totalsample'])],
                  ['Cumulative Eggs', safeText(item['cumulativeeggs'])],
                  ['Final Decision', safeText(item['finaldecision'])],
                  ['Created Date', formatScanReportDate(item['createdat'])],
                ],
              ),

              pw.SizedBox(height: 14),

              _pdfSection(
                title: 'Pesticide Information',
                rows: [
                  ['Pesticide Type', safeText(item['pesticidetype'])],
                  ['Pesticide Price', formatRM(item['pesticideprice'])],
                  ['Pesticide Rate', safeText(item['pesticiderate'])],
                  ['Pesticide Cost', formatRM(item['pesticidecost'])],
                  [
                    'Frequency / Year',
                    safeText(item['pesticidefrequencyperyear']),
                  ],
                ],
              ),

              pw.SizedBox(height: 14),

              _pdfSection(
                title: 'Labour & Yield Information',
                rows: [
                  ['Daily Labour Cost', formatRM(item['dailylabourcost'])],
                  [
                    'Farm Area Spray / Day',
                    safeText(item['farmareasprayperday']),
                  ],
                  [
                    'Wet Cocoa Bean Price / KG',
                    formatRM(item['wetcocoabeanpriceperkg']),
                  ],
                  [
                    'Expected Yield / Hectare',
                    safeText(item['expectedyieldperhectare']),
                  ],
                ],
              ),
            ];
          },
        ),
      );
    }

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileName,
    );
  }

  pw.Widget _pdfSection({
    required String title,
    required List<List<String>> rows,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(170),
              1: const pw.FlexColumnWidth(),
            },
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            children: rows.map((row) {
              return pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    color: PdfColors.grey100,
                    child: pw.Text(
                      row[0],
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      row[1],
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
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

    final existingIds = data.map(_reportId).toSet();
    selectedReportIds.removeWhere((id) => !existingIds.contains(id));
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

  void handleSelectionChanged(Map<String, dynamic> item, bool? selected) {
    final id = _reportId(item);
    if (id.isEmpty) return;

    setState(() {
      if (selected == true) {
        selectedReportIds.add(id);
      } else {
        selectedReportIds.remove(id);
      }
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

      selectedReportIds.remove(_reportId(item));

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

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
            onExportCsv: exportSelectedCsv,
            onExportPdf: exportSelectedPdf,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ScanReportTableSection(
              isLoading: isLoading,
              items: filtered,
              selectedIds: selectedReportIds,
              onView: (item) =>
                  showScanReportDetailsDialog(context: context, item: item),
              onDelete: handleDelete,
              onExportCsv: exportSingleCsv,
              onExportPdf: exportSinglePdf,
              onSelectionChanged: handleSelectionChanged,
            ),
          ),
        ],
      ),
    );
  }
}