// components/legend_component.dart
import 'package:flutter/material.dart';

class LegendComponent extends StatelessWidget {
  final String? selectedState;
  final Map<String, dynamic>? selectedStateData;
  final Color Function(String) getStateColor;
  final String Function(int) getDensityLevel;
  final String currentDataView;
  final VoidCallback? onClearSelection;

  // Define constant colors
  static const Color blue800 = Color(0xFF1565C0);
  static const Color blue700 = Color(0xFF1976D2);
  static const Color blue100 = Color(0xFFBBDEFB);
  static const Color blue50 = Color(0xFFE3F2FD);

  const LegendComponent({
    Key? key,
    this.selectedState,
    this.selectedStateData,
    required this.getStateColor,
    required this.getDensityLevel,
    required this.currentDataView,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.legend_toggle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  _getLegendTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildColorLegend(),
                const SizedBox(height: 16),
                _buildStatCard('Total Farmers', '2,876', Icons.people, Colors.blue),
                const SizedBox(height: 12),
                _buildStatCard('Total Scans', '18,987', Icons.photo_camera, Colors.green),
                const SizedBox(height: 12),
                _buildStatCard('Total Sprays', '10,876', Icons.spa, Colors.orange),
                const SizedBox(height: 12),
                _buildStatCard('Active States', '16', Icons.map, Colors.purple),
                
                if (selectedState != null) ...[
                  const SizedBox(height: 16),
                  _buildSelectedStateInfo(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLegendTitle() {
    switch (currentDataView) {
      case 'farmers': return 'Farmers Density Legend';
      case 'scans': return 'Scan Activity Legend';
      case 'sprays': return 'Spray Activity Legend';
      default: return 'Statistics Overview';
    }
  }

  Widget _buildColorLegend() {
    List<Map<String, dynamic>> legendItems = [];

    switch (currentDataView) {
      case 'farmers':
        legendItems = [
          {'range': '300+', 'label': 'Very High', 'color': Colors.red[700]!},
          {'range': '200-299', 'label': 'High', 'color': Colors.orange[700]!},
          {'range': '100-199', 'label': 'Medium', 'color': Colors.yellow[700]!},
          {'range': '50-99', 'label': 'Low', 'color': Colors.green[700]!},
          {'range': '0-49', 'label': 'Very Low', 'color': Colors.blue[700]!},
        ];
        break;
      
      case 'scans':
        legendItems = [
          {'range': '2000+', 'label': 'Very High', 'color': Colors.purple[800]!},
          {'range': '1500-1999', 'label': 'High', 'color': Colors.purple[600]!},
          {'range': '1000-1499', 'label': 'Medium', 'color': Colors.purple[400]!},
          {'range': '500-999', 'label': 'Low', 'color': Colors.purple[300]!},
          {'range': '0-499', 'label': 'Very Low', 'color': Colors.purple[200]!},
        ];
        break;
      
      case 'sprays':
        legendItems = [
          {'range': '1000+', 'label': 'Very High', 'color': Colors.teal[800]!},
          {'range': '750-999', 'label': 'High', 'color': Colors.teal[600]!},
          {'range': '500-749', 'label': 'Medium', 'color': Colors.teal[400]!},
          {'range': '250-499', 'label': 'Low', 'color': Colors.teal[300]!},
          {'range': '0-249', 'label': 'Very Low', 'color': Colors.teal[200]!},
        ];
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Scale',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...legendItems.map((item) => _buildLegendItem(
            item['color'] as Color,
            item['range'] as String,
            item['label'] as String,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String range, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$range ($label)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedStateInfo() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: blue50,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: blue100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: blue700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected: ${selectedState!}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blue800,
                ),
              ),
            ),
            if (onClearSelection != null)
              IconButton(
                onPressed: onClearSelection,
                icon: const Icon(Icons.close, size: 16, color: blue700),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        if (selectedStateData != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_getMetricName()}: ${selectedStateData![currentDataView]}',
            style: const TextStyle(
              color: blue700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level: ${getDensityLevel(selectedStateData![currentDataView])}',
            style: const TextStyle(
              color: blue700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    ),
  );
}

  String _getMetricName() {
    switch (currentDataView) {
      case 'farmers': return 'Farmers';
      case 'scans': return 'Scans';
      case 'sprays': return 'Sprays';
      default: return 'Value';
    }
  }
}