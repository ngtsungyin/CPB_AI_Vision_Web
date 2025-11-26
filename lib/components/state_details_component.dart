// components/state_details_component.dart
import 'package:flutter/material.dart';

class StateDetailsComponent extends StatelessWidget {
  final String selectedState;
  final Map<String, dynamic> selectedStateData;
  final Color Function(String) getStateColor;
  final String Function(int) getDensityLevel;
  final String currentDataView;
  final VoidCallback onClearSelection;

  const StateDetailsComponent({
    Key? key,
    required this.selectedState,
    required this.selectedStateData,
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
          // Details Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Selected State: $selectedState',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClearSelection,
                  icon: const Icon(Icons.close, color: Colors.blue),
                  tooltip: 'Clear selection',
                ),
              ],
            ),
          ),

          // Brief Details Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildDetailMetric(
                  'Farmers',
                  selectedStateData['farmers'],
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 24),
                _buildDetailMetric(
                  'Scans',
                  selectedStateData['scans'],
                  Icons.photo_camera,
                  Colors.green,
                ),
                const SizedBox(width: 24),
                _buildDetailMetric(
                  'Sprays',
                  selectedStateData['sprays'],
                  Icons.spa,
                  Colors.orange,
                ),
                const SizedBox(width: 24),
                _buildDetailMetric(
                  'Active Farms',
                  selectedStateData['active_farms'],
                  Icons.agriculture,
                  Colors.purple,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: getStateColor(selectedState),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_getCurrentMetricName()} Level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        getDensityLevel(selectedStateData[currentDataView]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMetric(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getCurrentMetricName() {
    switch (currentDataView) {
      case 'farmers': return 'Farmers';
      case 'scans': return 'Scans';
      case 'sprays': return 'Sprays';
      default: return 'Value';
    }
  }
}