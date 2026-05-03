import 'package:flutter/material.dart';

class LabourCostSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRefresh;

  const LabourCostSearchSection({
    super.key,
    required this.controller,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final searchField = TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search by farmer name, farm name, district, or state...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              refreshButton,
            ],
          );
        },
      ),
    );
  }
}