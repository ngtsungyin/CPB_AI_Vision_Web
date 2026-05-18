import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';
import '../helpers/scan_report_helper.dart';

class ScanReportTableSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Set<String> selectedIds;
  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onExportCsv;
  final Function(Map<String, dynamic>) onExportPdf;
  final Function(Map<String, dynamic>, bool?) onSelectionChanged;

  const ScanReportTableSection({
    super.key,
    required this.isLoading,
    required this.items,
    required this.selectedIds,
    required this.onView,
    required this.onDelete,
    required this.onExportCsv,
    required this.onExportPdf,
    required this.onSelectionChanged,
  });

  String _reportId(Map<String, dynamic> item) {
    return item['reportid']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<Map<String, dynamic>>(
      isLoading: isLoading,
      items: items,
      rowsPerPage: 10,
      emptyMessage: 'No scan reports found',
      columns: [
        AdminTableColumn(
          label: 'Select',
          width: 80,
          flexGrow: 0,
          cellBuilder: (_, item) {
            final id = _reportId(item);

            return Checkbox(
              value: selectedIds.contains(id),
              onChanged: (value) => onSelectionChanged(item, value),
            );
          },
        ),
        AdminTableColumn(
          label: 'Farmer',
          width: 180,
          flexGrow: 1.2,
          cellBuilder: (_, item) => AdminTableText(getFarmerName(item)),
        ),
        AdminTableColumn(
          label: 'Farm',
          width: 170,
          flexGrow: 1.2,
          cellBuilder: (_, item) => AdminTableText(getFarmName(item)),
        ),
        AdminTableColumn(
          label: 'Samples',
          width: 100,
          flexGrow: 0.6,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['totalsample'])),
        ),
        AdminTableColumn(
          label: 'Eggs',
          width: 100,
          flexGrow: 0.6,
          cellBuilder: (_, item) =>
              AdminTableText(safeText(item['cumulativeeggs'])),
        ),
        AdminTableColumn(
          label: 'Decision',
          width: 170,
          flexGrow: 1,
          cellBuilder: (_, item) =>
              _DecisionBadge(decision: safeText(item['finaldecision'])),
        ),
        AdminTableColumn(
          label: 'Pesticide Cost',
          width: 140,
          flexGrow: 0.8,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['pesticidecost'])),
        ),
        AdminTableColumn(
          label: 'Labour Cost',
          width: 140,
          flexGrow: 0.8,
          cellBuilder: (_, item) =>
              AdminTableText(formatRM(item['dailylabourcost'])),
        ),
        AdminTableColumn(
          label: 'Created',
          width: 140,
          flexGrow: 0.8,
          cellBuilder: (_, item) =>
              AdminTableText(formatScanReportDate(item['createdat'])),
        ),
        AdminTableColumn(
          label: 'Actions',
          width: 230,
          flexGrow: 0,
          cellBuilder: (_, item) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                tooltip: 'View report details',
                onPressed: () => onView(item),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Color(0xFF111827)),
                tooltip: 'Export this report as CSV',
                onPressed: () => onExportCsv(item),
              ),
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Colors.red,
                ),
                tooltip: 'Export this report as PDF',
                onPressed: () => onExportPdf(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete report',
                onPressed: () => onDelete(item),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String decision;

  const _DecisionBadge({required this.decision});

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(decision);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        decision,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
}
