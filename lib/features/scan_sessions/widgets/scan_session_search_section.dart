import 'package:flutter/material.dart';

class ScanSessionSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final String selectedDecision;
  final List<String> decisions;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onDecisionChanged;
  final VoidCallback onRefresh;

  const ScanSessionSearchSection({
    super.key,
    required this.controller,
    required this.selectedDecision,
    required this.decisions,
    required this.onSearch,
    required this.onDecisionChanged,
    required this.onRefresh,
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
          final isCompact = constraints.maxWidth < 850;

          final searchField = TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search by farmer, farm, decision, district, or state...',
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

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 12),
                decisionFilter,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: refreshButton,
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
            ],
          );
        },
      ),
    );
  }
}