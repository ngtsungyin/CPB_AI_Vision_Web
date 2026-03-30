import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cpbaivision_app/features/dashboard/services/dashboard_service.dart';

class AnalyticsChartCard extends StatefulWidget {
  const AnalyticsChartCard({super.key});

  @override
  State<AnalyticsChartCard> createState() => _AnalyticsChartCardState();
}

class _AnalyticsChartCardState extends State<AnalyticsChartCard> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  int _selectedMetric = 0; // 0 = scans, 1 = farms, 2 = users

  List<int> _scanData = List<int>.filled(7, 0);
  List<int> _farmData = List<int>.filled(7, 0);
  List<int> _userData = List<int>.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _dashboardService.getLast7DaysTrends();

      setState(() {
        _scanData = _safeIntList(result['scans']);
        _farmData = _safeIntList(result['farms']);
        _userData = _safeIntList(result['users']);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _scanData = List<int>.filled(7, 0);
        _farmData = List<int>.filled(7, 0);
        _userData = List<int>.filled(7, 0);
        _isLoading = false;
      });
    }
  }

  List<int> _safeIntList(dynamic rawList) {
    if (rawList is! List) {
      return List<int>.filled(7, 0);
    }

    return List<int>.generate(7, (index) {
      if (index >= rawList.length) return 0;

      final value = rawList[index];

      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;

      return 0;
    });
  }

  List<int> get _currentData {
    switch (_selectedMetric) {
      case 0:
        return _scanData;
      case 1:
        return _farmData;
      case 2:
        return _userData;
      default:
        return _scanData;
    }
  }

  String get _currentLabel {
    switch (_selectedMetric) {
      case 0:
        return 'Scans';
      case 1:
        return 'Farms';
      case 2:
        return 'Users';
      default:
        return 'Scans';
    }
  }

  Color get _currentColor {
    switch (_selectedMetric) {
      case 0:
        return const Color(0xFF2563EB);
      case 1:
        return const Color(0xFF16A34A);
      case 2:
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF2563EB);
    }
  }

  int get _total => _currentData.fold<int>(0, (sum, item) => sum + item);

  int get _highestValue {
    if (_currentData.isEmpty) return 0;
    return _currentData.reduce((a, b) => a > b ? a : b);
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: BarChart(_buildBarChartData()),
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
                  _buildToggleButtons(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTitleBlock()),
                  const SizedBox(width: 16),
                  _buildToggleButtons(),
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
          '7-Day Trend Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daily $_currentLabel activity for the last 7 days • Total: $_total • Peak: $_highestValue',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    final items = const [
      ('Scans', 0),
      ('Farms', 1),
      ('Users', 2),
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
    final selected = _selectedMetric == index;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedMetric = index),
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

  BarChartData _buildBarChartData() {
    final labels = _getLast7DayLabels();
    final maxY = _calculateMaxY();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: 0,
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
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 10,
          tooltipBgColor: Colors.black87,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final label =
                (group.x >= 0 && group.x < labels.length) ? labels[group.x] : '-';

            return BarTooltipItem(
              '$label\n${rod.toY.toInt()} $_currentLabel',
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
            reservedSize: 38,
            interval: maxY <= 10 ? 2 : null,
            getTitlesWidget: (value, meta) {
              if (value % 1 != 0) return const SizedBox.shrink();

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
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value % 1 != 0) return const SizedBox.shrink();

              final index = value.toInt();
              if (index < 0 || index >= labels.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(_currentData.length, (index) {
        final value = _currentData[index];

        return BarChartGroupData(
          x: index,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              width: 22,
              color: _currentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        );
      }),
    );
  }

  double _calculateMaxY() {
    if (_currentData.isEmpty) return 10;

    final highest = _currentData.reduce((a, b) => a > b ? a : b);

    if (highest <= 5) return 6;
    if (highest <= 10) return 12;
    return (highest * 1.2).ceilToDouble();
  }

  List<String> _getLast7DayLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add('${weekdays[date.weekday - 1]}\n${date.day}');
    }

    return labels;
  }
}