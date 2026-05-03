import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/widgets/admin_paginated_table.dart';
import '../helpers/scan_session_helper.dart';

class ScanSessionTableSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onView;

  const ScanSessionTableSection({
    super.key,
    required this.isLoading,
    required this.items,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPaginatedTable<Map<String, dynamic>>(
      isLoading: isLoading,
      items: items,
      rowsPerPage: 10,
      emptyMessage: 'No scan sessions found',
      columns: [
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
          label: 'Total Eggs',
          width: 110,
          flexGrow: 0.7,
          cellBuilder: (_, item) => AdminTableText(
            safeText(item['totaleggs']),
          ),
        ),
        AdminTableColumn(
          label: 'Average Eggs',
          width: 130,
          flexGrow: 0.7,
          cellBuilder: (_, item) => AdminTableText(
            safeText(item['averageeggs']),
          ),
        ),
        AdminTableColumn(
          label: 'Decision',
          width: 170,
          flexGrow: 1,
          cellBuilder: (_, item) => _DecisionBadge(
            decision: safeText(item['finaldecision']),
          ),
        ),
        AdminTableColumn(
          label: 'Status',
          width: 120,
          flexGrow: 0.7,
          cellBuilder: (_, item) => _CompletedBadge(
            completed: item['completed'] == true,
          ),
        ),
        AdminTableColumn(
          label: 'Date',
          width: 140,
          flexGrow: 0.8,
          cellBuilder: (_, item) => AdminTableText(
            formatScanSessionDate(item['sessiondate']),
          ),
        ),
        AdminTableColumn(
          label: 'Actions',
          width: 90,
          flexGrow: 0,
          cellBuilder: (_, item) => AdminTableActions(
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                tooltip: 'View session scans',
                onPressed: () => onView(item),
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

class _CompletedBadge extends StatelessWidget {
  final bool completed;

  const _CompletedBadge({required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        completed ? 'Completed' : 'Pending',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}