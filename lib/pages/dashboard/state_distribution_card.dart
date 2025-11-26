// pages/dashboard/state_distribution_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StateDistributionCard extends StatefulWidget {
  const StateDistributionCard({super.key});

  @override
  State<StateDistributionCard> createState() => _StateDistributionCardState();
}

class _StateDistributionCardState extends State<StateDistributionCard> {
  int _selectedBarChartType = 0; // 0: Scans, 1: Farms, 2: Users
  List<BarChartGroupData> _stateScanData = [];
  List<BarChartGroupData> _stateFarmData = [];
  List<BarChartGroupData> _stateUserData = [];
  bool _isChartLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _stateScanData = _generateStateBarData([120, 85, 95, 65, 110, 75, 90, 105, 80, 70, 55, 95, 85, 60], Colors.blue);
      _stateFarmData = _generateStateBarData([45, 32, 38, 28, 42, 30, 35, 40, 32, 28, 22, 36, 33, 25], Colors.green);
      _stateUserData = _generateStateBarData([65, 45, 52, 38, 58, 42, 48, 55, 45, 40, 32, 50, 46, 35], Colors.orange);
      _isChartLoading = false;
    });
  }

  List<BarChartGroupData> _generateStateBarData(List<int> values, Color color) {
    return List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index].toDouble(),
            color: color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  List<BarChartGroupData> get _currentBarData {
    switch (_selectedBarChartType) {
      case 0: return _stateScanData;
      case 1: return _stateFarmData;
      case 2: return _stateUserData;
      default: return _stateScanData;
    }
  }

  Color get _barChartColor {
    switch (_selectedBarChartType) {
      case 0: return Colors.blue;
      case 1: return Colors.green;
      case 2: return Colors.orange;
      default: return Colors.blue;
    }
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
            Row(
              children: [
                const Text(
                  'State Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildBarChartToggleButtons(),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Scans', 0),
          _buildToggleButton('Farms', 1),
          _buildToggleButton('Users', 2),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final isSelected = _selectedBarChartType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBarChartType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _barChartColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const states = ['JHR', 'KDH', 'KTN', 'MLK', 'NSN', 'PHG', 'PRK', 'PLS', 'PNG', 'SBH', 'SWK', 'SGR', 'TRG', 'KUL'];
                return value.toInt() < states.length
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          states[value.toInt()],
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                        ),
                      )
                    : const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _currentBarData,
      ),
    );
  }
}