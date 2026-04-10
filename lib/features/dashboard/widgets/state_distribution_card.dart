import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cpbaivision_app/features/dashboard/services/dashboard_service.dart';

class StateDistributionCard extends StatefulWidget {
  const StateDistributionCard({super.key});

  @override
  State<StateDistributionCard> createState() => _StateDistributionCardState();
}

class _StateDistributionCardState extends State<StateDistributionCard> {
  final DashboardService _dashboardService = DashboardService();

  int _selectedBarChartType = 0; // 0: Scans, 1: Farms
  List<BarChartGroupData> _stateScanData = [];
  List<BarChartGroupData> _stateFarmData = [];
  bool _isChartLoading = true;

  static const List<String> _stateCodes = [
    'JHR',
    'KDH',
    'KTN',
    'MLK',
    'NSN',
    'PHG',
    'PRK',
    'PLS',
    'PNG',
    'SBH',
    'SWK',
    'SGR',
    'TRG',
    'KUL',
  ];

  static const Map<String, String> _stateNameToCode = {
    'johor': 'JHR',
    'kedah': 'KDH',
    'kelantan': 'KTN',
    'melaka': 'MLK',
    'malacca': 'MLK',
    'negeri sembilan': 'NSN',
    'pahang': 'PHG',
    'perak': 'PRK',
    'perlis': 'PLS',
    'pulau pinang': 'PNG',
    'penang': 'PNG',
    'sabah': 'SBH',
    'sarawak': 'SWK',
    'selangor': 'SGR',
    'terengganu': 'TRG',
    'kuala lumpur': 'KUL',
    'wilayah persekutuan kuala lumpur': 'KUL',
    'w.p. kuala lumpur': 'KUL',
  };

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isChartLoading = true;
    });

    try {
      final farmCounts = await _dashboardService.getFarmCountByState();
      final scanCounts = await _dashboardService.getScanCountByState();

      final normalizedFarmCounts = _normalizeCountsByStateCode(farmCounts);
      final normalizedScanCounts = _normalizeCountsByStateCode(scanCounts);

      setState(() {
        _stateFarmData = _generateStateBarDataFromMap(
          normalizedFarmCounts,
          const Color(0xFF16A34A),
        );
        _stateScanData = _generateStateBarDataFromMap(
          normalizedScanCounts,
          const Color(0xFF2563EB),
        );
        _isChartLoading = false;
      });
    } catch (_) {
      setState(() {
        _stateFarmData = _generateStateBarDataFromMap(
          {},
          const Color(0xFF16A34A),
        );
        _stateScanData = _generateStateBarDataFromMap(
          {},
          const Color(0xFF2563EB),
        );
        _isChartLoading = false;
      });
    }
  }

  Map<String, int> _normalizeCountsByStateCode(Map<String, int> rawCounts) {
    final Map<String, int> normalized = {
      for (final code in _stateCodes) code: 0,
    };

    for (final entry in rawCounts.entries) {
      final rawKey = entry.key.trim();
      if (rawKey.isEmpty) continue;

      final upper = rawKey.toUpperCase();

      if (_stateCodes.contains(upper)) {
        normalized[upper] = (normalized[upper] ?? 0) + entry.value;
        continue;
      }

      final lower = rawKey.toLowerCase();
      final mappedCode = _stateNameToCode[lower];

      if (mappedCode != null) {
        normalized[mappedCode] = (normalized[mappedCode] ?? 0) + entry.value;
      }
    }

    return normalized;
  }

  List<BarChartGroupData> _generateStateBarDataFromMap(
    Map<String, int> values,
    Color color,
  ) {
    return List.generate(_stateCodes.length, (index) {
      final code = _stateCodes[index];
      final value = values[code] ?? 0;

      return BarChartGroupData(
        x: index,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: color,
            width: 14,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(5),
            ),
          ),
        ],
      );
    });
  }

  List<BarChartGroupData> get _currentBarData {
    switch (_selectedBarChartType) {
      case 0:
        return _stateScanData;
      case 1:
        return _stateFarmData;
      default:
        return _stateScanData;
    }
  }

  Color get _barChartColor {
    switch (_selectedBarChartType) {
      case 0:
        return const Color(0xFF2563EB);
      case 1:
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF2563EB);
    }
  }

  String get _selectedMetricLabel {
    switch (_selectedBarChartType) {
      case 0:
        return 'Scans';
      case 1:
        return 'Farms';
      default:
        return 'Scans';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            Expanded(
              child: _isChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RepaintBoundary(child: _buildBarChart()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleBlock(),
                  const SizedBox(height: 12),
                  _buildBarChartToggleButtons(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTitleBlock()),
                  const SizedBox(width: 16),
                  _buildBarChartToggleButtons(),
                ],
              );
      },
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Compare $_selectedMetricLabel performance across Malaysian states.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartToggleButtons() {
    final items = const [
      ('Scans', 0),
      ('Farms', 1),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map((item) => _buildToggleButton(item.$1, item.$2))
            .toList(),
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final selected = _selectedBarChartType == index;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedBarChartType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxY = _calculateMaxY();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_stateCodes[group.x]}\n${rod.toY.toInt()} $_selectedMetricLabel',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: maxY <= 10 ? 2 : null,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _stateCodes.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _stateCodes[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 10 ? 2 : null,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: _currentBarData,
      ),
    );
  }

  double _calculateMaxY() {
    final data = _currentBarData;
    if (data.isEmpty) return 10;

    final highest = data
        .map((e) => e.barRods.first.toY)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    if (highest <= 5) return 6;
    if (highest <= 10) return 12;
    return (highest * 1.2).ceilToDouble();
  }
}