// components/map_component.dart
import 'package:cpbaivision_app/models/map_data_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapComponent extends StatefulWidget {
  final MapShapeSource mapSource;
  final List<MapDataModel> mapDataList;
  final Function(String) onStateSelected;
  final String? selectedState;
  final String currentDataView;

  const MapComponent({
    Key? key,
    required this.mapSource,
    required this.mapDataList,
    required this.onStateSelected,
    this.selectedState,
    required this.currentDataView,
  }) : super(key: key);

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  int? _selectedIndex;
  MapShapeLayerController? _layerController;

  @override
  void initState() {
    super.initState();
    _layerController = MapShapeLayerController();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (widget.selectedState != null) {
      _selectedIndex = widget.mapDataList.indexWhere(
        (data) => data.statename == widget.selectedState
      );
      if (_selectedIndex != -1) {
        _layerController?.selectedIndex = _selectedIndex!;
      }
    } else {
      _selectedIndex = null;
      _layerController?.selectedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfMaps(
      layers: [
        MapShapeLayer(
          controller: _layerController,
          source: widget.mapSource,
          showDataLabels: false,
          tooltipSettings: MapTooltipSettings(
            color: Colors.white,
            strokeColor: Colors.grey[300]!,
            strokeWidth: 1,
            // Customize tooltip position and behavior
          ),
          // Provide the custom tooltip builder on the MapShapeLayer itself
          shapeTooltipBuilder: (BuildContext context, int index) {
            return _buildCustomTooltip(widget.mapDataList[index]);
          },
          strokeColor: Colors.white,
          strokeWidth: 1.5,
          selectionSettings: MapSelectionSettings(
            color: Colors.orange.withOpacity(0.7),
            strokeColor: Colors.orange,
            strokeWidth: 2.0,
          ),
          onSelectionChanged: (int index) {
            if (index >= 0 && index < widget.mapDataList.length) {
              final selectedData = widget.mapDataList[index];
              widget.onStateSelected(selectedData.statename);
              setState(() {
                _selectedIndex = index;
              });
            } else {
              setState(() {
                _selectedIndex = null;
              });
            }
          },
          selectedIndex: _selectedIndex ?? -1,
          loadingBuilder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomTooltip(MapDataModel data) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // State Name Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _getCurrentViewColor(),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.statename,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTooltipMetric('Farmers', '${data.farmers}', Colors.blue),
              _buildTooltipMetric('Scans', '${data.scans}', Colors.green),
              _buildTooltipMetric('Sprays', '${data.sprays}', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          
          // Current View Highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCurrentViewColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _getCurrentViewColor().withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCurrentViewIcon(),
                  color: _getCurrentViewColor(),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_getCurrentViewName()}: ${_getCurrentViewValue(data)}',
                  style: TextStyle(
                    color: _getCurrentViewColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          
          // Click Hint
          Text(
            'Click to view details',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipMetric(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getCurrentViewColor() {
    switch (widget.currentDataView) {
      case 'farmers': return Colors.blue;
      case 'scans': return Colors.purple;
      case 'sprays': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getCurrentViewIcon() {
    switch (widget.currentDataView) {
      case 'farmers': return Icons.people;
      case 'scans': return Icons.photo_camera;
      case 'sprays': return Icons.spa;
      default: return Icons.data_usage;
    }
  }

  String _getCurrentViewName() {
    switch (widget.currentDataView) {
      case 'farmers': return 'Farmers';
      case 'scans': return 'Scans';
      case 'sprays': return 'Sprays';
      default: return 'Data';
    }
  }

  int _getCurrentViewValue(MapDataModel data) {
    switch (widget.currentDataView) {
      case 'farmers': return data.farmers;
      case 'scans': return data.scans;
      case 'sprays': return data.sprays;
      default: return 0;
    }
  }

  @override
  void dispose() {
    _layerController?.dispose();
    super.dispose();
  }
}

extension on MapShapeLayerController? {
  set selectedIndex(int selectedIndex) {}
}