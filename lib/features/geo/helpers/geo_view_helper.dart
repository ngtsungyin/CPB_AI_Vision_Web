import 'package:flutter/material.dart';

class GeoLegendItem {
  final String label;
  final String rangeLabel;
  final Color color;

  const GeoLegendItem({
    required this.label,
    required this.rangeLabel,
    required this.color,
  });
}

class GeoMetricThresholds {
  final double q1;
  final double q2;
  final double q3;

  const GeoMetricThresholds({
    required this.q1,
    required this.q2,
    required this.q3,
  });
}

List<num> getGeoMetricValuesFromStateStatistics({
  required Map<String, Map<String, dynamic>> stateStatistics,
  required String currentDataView,
}) {
  return stateStatistics.values
      .map((entry) => (entry[currentDataView] ?? 0) as num)
      .toList();
}

GeoMetricThresholds getGeoMetricThresholds({
  required Iterable<num> metricValues,
}) {
  final values = metricValues.map((e) => e.toDouble()).toList()..sort();

  if (values.isEmpty) {
    return const GeoMetricThresholds(q1: 0, q2: 0, q3: 0);
  }

  if (values.length == 1) {
    return GeoMetricThresholds(
      q1: values.first,
      q2: values.first,
      q3: values.first,
    );
  }

  double percentile(double p) {
    final position = (values.length - 1) * p;
    final lower = position.floor();
    final upper = position.ceil();

    if (lower == upper) return values[lower];

    final fraction = position - lower;
    return values[lower] + (values[upper] - values[lower]) * fraction;
  }

  return GeoMetricThresholds(
    q1: percentile(0.25),
    q2: percentile(0.50),
    q3: percentile(0.75),
  );
}

Color getGeoStateColor({
  required String stateName,
  required String currentDataView,
  required Map<String, Map<String, dynamic>> stateStatistics,
}) {
  final stats = stateStatistics[stateName];
  if (stats == null) return const Color(0xFFE5E7EB);

  final value = (stats[currentDataView] ?? 0) as num;
  final thresholds = getGeoMetricThresholds(
    metricValues: getGeoMetricValuesFromStateStatistics(
      stateStatistics: stateStatistics,
      currentDataView: currentDataView,
    ),
  );

  return getGeoColorForValue(
    currentDataView: currentDataView,
    value: value,
    thresholds: thresholds,
  );
}

Color getGeoColorForValue({
  required String currentDataView,
  required num value,
  required GeoMetricThresholds thresholds,
}) {
  final palette = _paletteForMetric(currentDataView);

  if (value <= thresholds.q1) return palette[0];
  if (value <= thresholds.q2) return palette[1];
  if (value <= thresholds.q3) return palette[2];
  return palette[3];
}

String getGeoDensityLevel({
  required num value,
  required String currentDataView,
  required Iterable<num> metricValues,
}) {
  final thresholds = getGeoMetricThresholds(metricValues: metricValues);

  if (value <= thresholds.q1) return 'Low';
  if (value <= thresholds.q2) return 'Moderate';
  if (value <= thresholds.q3) return 'High';
  return 'Very High';
}

String getGeoCurrentDataViewTitle(String currentDataView) {
  switch (currentDataView) {
    case 'farmers':
      return 'Farmers Distribution';
    case 'scans':
      return 'Scan Activity';
    case 'yield_revenue':
      return 'Yield Revenue';
    default:
      return 'Malaysia Map';
  }
}

List<GeoLegendItem> getGeoLegendItems({
  required String currentDataView,
  required Iterable<num> metricValues,
}) {
  final thresholds = getGeoMetricThresholds(metricValues: metricValues);
  final palette = _paletteForMetric(currentDataView);

  return [
    GeoLegendItem(
      label: 'Low',
      rangeLabel:
          '≤ ${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q1)}',
      color: palette[0],
    ),
    GeoLegendItem(
      label: 'Moderate',
      rangeLabel:
          '${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q1)} – ${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q2)}',
      color: palette[1],
    ),
    GeoLegendItem(
      label: 'High',
      rangeLabel:
          '${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q2)} – ${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q3)}',
      color: palette[2],
    ),
    GeoLegendItem(
      label: 'Very High',
      rangeLabel:
          '> ${formatGeoMetricValue(currentDataView: currentDataView, value: thresholds.q3)}',
      color: palette[3],
    ),
  ];
}

String formatGeoMetricValue({
  required String currentDataView,
  required num value,
}) {
  if (currentDataView == 'yield_revenue') {
    return 'RM ${_formatNumber(value, decimals: 2)}';
  }
  return _formatNumber(value, decimals: 0);
}

String _formatNumber(num value, {required int decimals}) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = _addThousandsSeparators(parts[0]);

  final result = decimals > 0 ? '$whole.${parts[1]}' : whole;
  return negative ? '-$result' : result;
}

String _addThousandsSeparators(String digits) {
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

List<Color> _paletteForMetric(String currentDataView) {
  switch (currentDataView) {
    case 'farmers':
      return const [
        Color(0xFFDBEAFE),
        Color(0xFF93C5FD),
        Color(0xFF3B82F6),
        Color(0xFF1D4ED8),
      ];
    case 'scans':
      return const [
        Color(0xFFE9D5FF),
        Color(0xFFC084FC),
        Color(0xFFA855F7),
        Color(0xFF7E22CE),
      ];
    case 'yield_revenue':
      return const [
        Color(0xFFDCFCE7),
        Color(0xFF86EFAC),
        Color(0xFF22C55E),
        Color(0xFF166534),
      ];
    default:
      return const [
        Color(0xFFE5E7EB),
        Color(0xFFD1D5DB),
        Color(0xFF9CA3AF),
        Color(0xFF4B5563),
      ];
  }
}