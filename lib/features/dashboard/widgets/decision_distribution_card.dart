import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cpbaivision_app/features/dashboard/services/dashboard_service.dart';

class DecisionDistributionCard extends StatefulWidget {
  const DecisionDistributionCard({super.key});

  @override
  State<DecisionDistributionCard> createState() =>
      _DecisionDistributionCardState();
}

class _DecisionDistributionCardState extends State<DecisionDistributionCard> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  int _treatCount = 0;
  int _continueSamplingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDecisionData();
  }

  Future<void> _loadDecisionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _dashboardService.getDecisionDistribution();

      setState(() {
        _treatCount = (result['treat'] as num?)?.toInt() ?? 0;
        _continueSamplingCount =
            (result['continue_sampling'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });

      print('Decision result: $result');
    } catch (_) {
      setState(() {
        _treatCount = 0;
        _continueSamplingCount = 0;
        _isLoading = false;
      });
    }
  }

  int get _total => _treatCount + _continueSamplingCount;

  double get _treatPercentage {
    if (_total == 0) return 0;
    return (_treatCount / _total) * 100;
  }

  double get _continueSamplingPercentage {
    if (_total == 0) return 0;
    return (_continueSamplingCount / _total) * 100;
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
                  const Text(
                    'Decision Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final decisions from completed scan sessions.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 42,
                                sectionsSpace: 2,
                                pieTouchData: PieTouchData(enabled: true),
                                sections: _buildSections(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: _buildLegend(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    if (_total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          radius: 50,
          title: 'No Data',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: (_treatCount).toDouble(),
        color: const Color(0xFFDC2626),
        radius: 54,
        title: '${_treatPercentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: _continueSamplingCount.toDouble(),
        color: const Color(0xFF16A34A),
        radius: 54,
        title: '${_continueSamplingPercentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(
          color: const Color(0xFFDC2626),
          title: 'Treat',
          count: _treatCount,
          percentage: _treatPercentage,
        ),
        const SizedBox(height: 16),
        _buildLegendItem(
          color: const Color(0xFF16A34A),
          title: 'Continue Sampling',
          count: _continueSamplingCount,
          percentage: _continueSamplingPercentage,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total completed sessions analyzed: $_total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required int count,
    required double percentage,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count sessions • ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}