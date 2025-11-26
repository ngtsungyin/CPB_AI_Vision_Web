// components/state_statistics_component.dart
import 'package:flutter/material.dart';

class StateStatisticsComponent extends StatelessWidget {
  final String stateName;
  final Map<String, dynamic> stateData;
  final String currentDataView;

  const StateStatisticsComponent({
    Key? key,
    required this.stateName,
    required this.stateData,
    required this.currentDataView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Statistics Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.green[100]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '$stateName - Detailed Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last Updated: ${stateData['last_updated'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistics Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Key Metrics Row
                _buildKeyMetricsRow(),
                const SizedBox(height: 24),
                
                // Detailed Statistics Grid
                _buildStatisticsGrid(),
                const SizedBox(height: 16),
                
                // Performance Indicators
                _buildPerformanceIndicators(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        _buildMetricCard(
          'Total Farmers',
          stateData['farmers'].toString(),
          Icons.people,
          Colors.blue,
          'Active agricultural workers',
        ),
        const SizedBox(width: 16),
        _buildMetricCard(
          'Active Farms',
          stateData['active_farms'].toString(),
          Icons.agriculture,
          Colors.green,
          'Operational farm units',
        ),
        const SizedBox(width: 16),
        _buildMetricCard(
          'Crop Yield (tons)',
          stateData['crop_yield'].toString(),
          Icons.grass,
          Colors.orange,
          'Annual production',
        ),
        const SizedBox(width: 16),
        _buildMetricCard(
          'Revenue (RM)',
          _formatCurrency(stateData['revenue']),
          Icons.attach_money,
          Colors.purple,
          'Annual revenue',
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildStatItem('Total Scans', stateData['scans'].toString(), Icons.photo_camera, Colors.green),
        _buildStatItem('Total Sprays', stateData['sprays'].toString(), Icons.spa, Colors.orange),
        _buildStatItem('Growth Rate', '${stateData['growth_rate']}%', Icons.trending_up, Colors.red),
        _buildStatItem('Scan/Farmer Ratio', _calculateRatio(stateData['scans'], stateData['farmers']), Icons.analytics, Colors.purple),
        _buildStatItem('Spray/Farmer Ratio', _calculateRatio(stateData['sprays'], stateData['farmers']), Icons.water_drop, Colors.blue),
        _buildStatItem('Yield/Farmer (tons)', _calculateRatio(stateData['crop_yield'], stateData['farmers']), Icons.emoji_events, Colors.amber),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators() {
    final growthRate = stateData['growth_rate'] ?? 0.0;
    Color growthColor = Colors.grey;
    IconData growthIcon = Icons.trending_flat;

    if (growthRate > 10) {
      growthColor = Colors.green;
      growthIcon = Icons.trending_up;
    } else if (growthRate > 5) {
      growthColor = Colors.blue;
      growthIcon = Icons.trending_up;
    } else if (growthRate < 0) {
      growthColor = Colors.red;
      growthIcon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: growthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(growthIcon, color: growthColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Indicator',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Growth Rate: ${growthRate}%',
                  style: TextStyle(
                    color: growthColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPerformanceMessage(growthRate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: growthColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getPerformanceLevel(growthRate),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount is int) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)}K';
      }
      return amount.toString();
    }
    return amount?.toString() ?? '0';
  }

  String _calculateRatio(int numerator, int denominator) {
    if (denominator == 0) return '0.0';
    return (numerator / denominator).toStringAsFixed(1);
  }

  String _getPerformanceMessage(double growthRate) {
    if (growthRate > 15) return 'Exceptional growth performance';
    if (growthRate > 10) return 'Strong growth momentum';
    if (growthRate > 5) return 'Steady growth pattern';
    if (growthRate > 0) return 'Moderate growth';
    if (growthRate == 0) return 'Stable performance';
    return 'Needs improvement';
  }

  String _getPerformanceLevel(double growthRate) {
    if (growthRate > 15) return 'EXCELLENT';
    if (growthRate > 10) return 'GOOD';
    if (growthRate > 5) return 'FAIR';
    if (growthRate > 0) return 'AVERAGE';
    return 'POOR';
  }
}