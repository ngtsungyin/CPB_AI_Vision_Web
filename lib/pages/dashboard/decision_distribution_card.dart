// pages/dashboard/decision_distribution_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DecisionDistributionCard extends StatefulWidget {
  const DecisionDistributionCard({super.key});

  @override
  State<DecisionDistributionCard> createState() => _DecisionDistributionCardState();
}

class _DecisionDistributionCardState extends State<DecisionDistributionCard> {
  List<PieChartSectionData> _spraySamplingData = [];
  bool _isChartLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _spraySamplingData = _generateSpraySamplingData();
      _isChartLoading = false;
    });
  }

  List<PieChartSectionData> _generateSpraySamplingData() {
    return [
      PieChartSectionData(
        color: Colors.red,
        value: 35,
        title: '35%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 65,
        title: '65%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spray vs Sampling Distribution',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPieChart(),
            ),
            const SizedBox(height: 16),
            _buildPieChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: _spraySamplingData,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildPieChartLegend() {
    return Column(
      children: [
        _buildLegendItem(
          Colors.red, 
          'Spray Recommendation (35%) - Immediate pest control needed'
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          Colors.green, 
          'Continue Sampling (65%) - Monitor and continue regular sampling'
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}