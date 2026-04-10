import 'package:flutter/material.dart';

class GeoPageHeader extends StatelessWidget {
  final String currentMetricLabel;
  final String? selectedState;

  const GeoPageHeader({
    super.key,
    required this.currentMetricLabel,
    required this.selectedState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextBlock(),
                const SizedBox(height: 16),
                _buildMetaChips(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTextBlock()),
              const SizedBox(width: 16),
              _buildMetaChips(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geo Analytics Overview',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore state-level distribution, compare operational activity, and inspect performance patterns across the map.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _HeaderChip(
          icon: Icons.layers_rounded,
          label: currentMetricLabel,
        ),
        _HeaderChip(
          icon: Icons.flag_circle_rounded,
          label: selectedState ?? 'All States',
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}