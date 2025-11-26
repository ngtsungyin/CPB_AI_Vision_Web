// pages/dashboard/analytics_chart_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsChartCard extends StatefulWidget {
  const AnalyticsChartCard({super.key});

  @override
  State<AnalyticsChartCard> createState() => _AnalyticsChartCardState();
}

class _AnalyticsChartCardState extends State<AnalyticsChartCard> {
  int _selectedChartType = 0; // 0: Scans, 1: Users, 2: Farms
  List<FlSpot> _scanData = [];
  List<FlSpot> _userData = [];
  List<FlSpot> _farmData = [];
  bool _isChartLoading = true;

  // Days of the week
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      // Sample data for 7 days
      _scanData = [
        FlSpot(0, 45), FlSpot(1, 52), FlSpot(2, 48), 
        FlSpot(3, 65), FlSpot(4, 58), FlSpot(5, 72), FlSpot(6, 80),
      ];
      
      _userData = [
        FlSpot(0, 120), FlSpot(1, 135), FlSpot(2, 142), 
        FlSpot(3, 156), FlSpot(4, 168), FlSpot(5, 175), FlSpot(6, 189),
      ];
      
      _farmData = [
        FlSpot(0, 45), FlSpot(1, 48), FlSpot(2, 52), 
        FlSpot(3, 55), FlSpot(4, 58), FlSpot(5, 60), FlSpot(6, 62),
      ];
      
      _isChartLoading = false;
    });
  }

  List<FlSpot> get _currentData {
    switch (_selectedChartType) {
      case 0: return _scanData;
      case 1: return _userData;
      case 2: return _farmData;
      default: return _scanData;
    }
  }

  Color get _chartColor {
    switch (_selectedChartType) {
      case 0: return Colors.blue;
      case 1: return Colors.green;
      case 2: return Colors.orange;
      default: return Colors.blue;
    }
  }

  String get _currentChartTitle {
    switch (_selectedChartType) {
      case 0: return 'Daily Scans';
      case 1: return 'Daily Users';
      case 2: return 'Daily Farms';
      default: return 'Daily Scans';
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
                Text(
                  _currentChartTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildChartToggleButtons(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: _isChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Scans', 0),
          _buildToggleButton('Users', 1),
          _buildToggleButton('Farms', 2),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final isSelected = _selectedChartType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _chartColor : Colors.transparent,
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

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getGridInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // This ensures one label per day
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _days[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getLeftAxisInterval(),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _currentData,
            isCurved: true,
            color: _chartColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: _chartColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _chartColor.withOpacity(0.3),
                  _chartColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: 6, // 0-6 for 7 days
        minY: 0,
        maxY: _getMaxY(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipBorder: BorderSide(color: Colors.grey[300]!),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.spotIndex;
                return LineTooltipItem(
                  '${_days[index]}: ${touchedSpot.y.toInt()}',
                  TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    final currentData = _currentData;
    if (currentData.isEmpty) return 100;
    final maxValue = currentData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.15).ceilToDouble(); // Add 15% padding
  }

  double _getGridInterval() {
    final maxY = _getMaxY();
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 200) return 40;
    return 50;
  }

  double _getLeftAxisInterval() {
    final maxY = _getMaxY();
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 200) return 40;
    return 50;
  }
}