import 'package:flutter/material.dart';
import 'package:cpbaivision_app/features/geo/helpers/geo_view_helper.dart';

class LegendComponent extends StatelessWidget {
  final String? selectedState;
  final Map<String, dynamic>? selectedStateData;
  final List<num> metricValues;
  final String currentDataView;
  final VoidCallback? onClearSelection;

  const LegendComponent({
    super.key,
    this.selectedState,
    this.selectedStateData,
    required this.metricValues,
    required this.currentDataView,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final legendItems = getGeoLegendItems(
      currentDataView: currentDataView,
      metricValues: metricValues,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendMetricBadge(
          label: _getLegendTitle(),
          accent: _getMetricColor(),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _LegendRangeCard(
                  title: 'Distribution Range',
                  subtitle: 'Percentile-based thresholds',
                  items: legendItems,
                ),
                const SizedBox(height: 14),
                _SelectedStateCard(
                  selectedState: selectedState,
                  selectedStateData: selectedStateData,
                  metricValues: metricValues,
                  currentDataView: currentDataView,
                  onClearSelection: onClearSelection,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getLegendTitle() {
    switch (currentDataView) {
      case 'farmers':
        return 'Farmers';
      case 'scans':
        return 'Scans';
      case 'yield_revenue':
        return 'Yield Revenue';
      default:
        return 'Metric';
    }
  }

  Color _getMetricColor() {
    switch (currentDataView) {
      case 'farmers':
        return const Color(0xFF1D4ED8);
      case 'scans':
        return const Color(0xFF7E22CE);
      case 'yield_revenue':
        return const Color(0xFF166534);
      default:
        return Colors.grey;
    }
  }
}

class _LegendMetricBadge extends StatelessWidget {
  final String label;
  final Color accent;

  const _LegendMetricBadge({
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            '$label Legend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRangeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GeoLegendItem> items;

  const _LegendRangeCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => _LegendStripeRow(item: item)),
        ],
      ),
    );
  }
}

class _LegendStripeRow extends StatelessWidget {
  final GeoLegendItem item;

  const _LegendStripeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.82),
                  item.color,
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.rangeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedStateCard extends StatelessWidget {
  final String? selectedState;
  final Map<String, dynamic>? selectedStateData;
  final List<num> metricValues;
  final String currentDataView;
  final VoidCallback? onClearSelection;

  const _SelectedStateCard({
    required this.selectedState,
    required this.selectedStateData,
    required this.metricValues,
    required this.currentDataView,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedState == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected State',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Click a state on the map to inspect its metric level and percentile classification.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final value = (selectedStateData?[currentDataView] ?? 0) as num;
    final density = getGeoDensityLevel(
      value: value,
      currentDataView: currentDataView,
      metricValues: metricValues,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_rounded,
                size: 18,
                color: Color(0xFF111827),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedState!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (onClearSelection != null)
                TextButton.icon(
                  onPressed: onClearSelection,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _StateInfoPill(
            label: _metricName(currentDataView),
            value: formatGeoMetricValue(
              currentDataView: currentDataView,
              value: value,
            ),
          ),
          const SizedBox(height: 10),
          _StateInfoPill(
            label: 'Density Level',
            value: density,
          ),
        ],
      ),
    );
  }

  String _metricName(String metric) {
    switch (metric) {
      case 'farmers':
        return 'Farmers';
      case 'scans':
        return 'Scans';
      case 'yield_revenue':
        return 'Yield Revenue';
      default:
        return 'Metric';
    }
  }
}

class _StateInfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _StateInfoPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}