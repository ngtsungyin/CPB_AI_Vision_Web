import 'package:flutter/material.dart';

class GeoDataViewSelector extends StatelessWidget {
  final String currentDataView;
  final ValueChanged<String> onChanged;

  const GeoDataViewSelector({
    super.key,
    required this.currentDataView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final views = const [
      {'key': 'farmers', 'label': 'Farmers', 'icon': Icons.people_alt_rounded},
      {'key': 'scans', 'label': 'Scans', 'icon': Icons.document_scanner_rounded},
      {'key': 'yield_revenue', 'label': 'Yield Revenue', 'icon': Icons.paid_rounded},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metric View',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch the map to compare state performance across different activity types.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isNarrow
                  ? Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: views.map((view) {
                        return _MetricChip(
                          label: view['label'] as String,
                          icon: view['icon'] as IconData,
                          selected: currentDataView == view['key'],
                          onTap: () => onChanged(view['key'] as String),
                        );
                      }).toList(),
                    )
                  : Row(
                      children: views.map((view) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _MetricChip(
                              label: view['label'] as String,
                              icon: view['icon'] as IconData,
                              selected: currentDataView == view['key'],
                              onTap: () => onChanged(view['key'] as String),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MetricChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.black87 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}