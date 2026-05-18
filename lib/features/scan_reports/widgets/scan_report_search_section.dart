import 'package:flutter/material.dart';

class ScanReportSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final String selectedDecision;
  final List<String> decisions;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onDecisionChanged;
  final VoidCallback onRefresh;
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  const ScanReportSearchSection({
    super.key,
    required this.controller,
    required this.selectedDecision,
    required this.decisions,
    required this.onSearch,
    required this.onDecisionChanged,
    required this.onRefresh,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = decisions.contains(selectedDecision)
        ? selectedDecision
        : 'All';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 980;

          final searchField = TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText:
                  'Search by farmer, farm, decision, district, or state...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );

          final decisionFilter = DropdownButtonFormField<String>(
            value: safeValue,
            isExpanded: true,
            items: decisions.map((decision) {
              return DropdownMenuItem<String>(
                value: decision,
                child: Text(
                  decision,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onDecisionChanged,
            decoration: InputDecoration(
              labelText: 'Decision',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          );

          final refreshButton = ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          );

          final csvButton = ElevatedButton.icon(
            onPressed: onExportCsv,
            icon: const Icon(Icons.download),
            label: const Text('Selected CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
            ),
          );

          final pdfButton = ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Selected PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 12),
                decisionFilter,
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [refreshButton, csvButton, pdfButton],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              SizedBox(width: 220, child: decisionFilter),
              const SizedBox(width: 12),
              refreshButton,
              const SizedBox(width: 12),
              csvButton,
              const SizedBox(width: 12),
              pdfButton,
            ],
          );
        },
      ),
    );
  }
}
