import 'package:cpbaivision_app/features/geo/helpers/geo_view_helper.dart';
import 'package:cpbaivision_app/shared/models/map_data_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapComponent extends StatefulWidget {
  final MapShapeSource mapSource;
  final List<MapDataModel> mapDataList;
  final List<num> metricValues;
  final Function(String) onStateSelected;
  final String? selectedState;
  final String currentDataView;

  const MapComponent({
    super.key,
    required this.mapSource,
    required this.mapDataList,
    required this.metricValues,
    required this.onStateSelected,
    this.selectedState,
    required this.currentDataView,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _syncSelectedIndex();
  }

  @override
  void didUpdateWidget(covariant MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedStateChanged =
        oldWidget.selectedState != widget.selectedState;
    final dataChanged = oldWidget.mapDataList != widget.mapDataList;
    final metricChanged = oldWidget.currentDataView != widget.currentDataView;

    if (selectedStateChanged || dataChanged || metricChanged) {
      _syncSelectedIndex();
    }
  }

  void _syncSelectedIndex() {
    if (widget.selectedState == null) {
      _selectedIndex = -1;
      return;
    }

    final index = widget.mapDataList.indexWhere(
      (data) => data.statename == widget.selectedState,
    );

    _selectedIndex = index >= 0 ? index : -1;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndex >= 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: hasSelection ? 1.015 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: _getCurrentViewColor().withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: SfMaps(
            layers: [
              MapShapeLayer(
                source: widget.mapSource,
                showDataLabels: false,
                strokeColor: Colors.white,
                strokeWidth: 1.2,
                selectedIndex: _selectedIndex,
                selectionSettings: MapSelectionSettings(
                  color: _getCurrentViewColor().withOpacity(0.26),
                  strokeColor: _getCurrentViewColor(),
                  strokeWidth: 2.4,
                ),
                tooltipSettings: const MapTooltipSettings(
                  color: Colors.transparent,
                  strokeColor: Colors.transparent,
                  strokeWidth: 0,
                ),
                shapeTooltipBuilder: (BuildContext context, int index) {
                  if (index < 0 || index >= widget.mapDataList.length) {
                    return const SizedBox.shrink();
                  }
                  return _buildCustomTooltip(context, widget.mapDataList[index]);
                },
                onSelectionChanged: (int index) {
                  if (index >= 0 && index < widget.mapDataList.length) {
                    final selectedData = widget.mapDataList[index];
                    widget.onStateSelected(selectedData.statename);

                    setState(() {
                      _selectedIndex = index;
                    });
                  } else {
                    setState(() {
                      _selectedIndex = -1;
                    });
                  }
                },
                loadingBuilder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTooltip(BuildContext context, MapDataModel data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    final currentMetricLabel = _getCurrentViewName();
    final currentMetricValue = _getCurrentViewValue(data);
    final densityLabel = getGeoDensityLevel(
      value: currentMetricValue,
      currentDataView: widget.currentDataView,
      metricValues: widget.metricValues,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isNarrow ? 150 : 190,
        maxWidth: isNarrow ? 200 : 250,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(isNarrow ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.black87,
              fontSize: isNarrow ? 11 : 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: isNarrow ? 13 : 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'State Insight',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isNarrow ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isNarrow ? 26 : 28,
                      height: isNarrow ? 26 : 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.place_rounded,
                        size: isNarrow ? 15 : 16,
                        color: _getCurrentViewColor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.statename,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isNarrow ? 12 : 13,
                          letterSpacing: -0.1,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getCurrentViewColor().withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCurrentViewColor().withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: data.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$currentMetricLabel: ${formatGeoMetricValue(currentDataView: widget.currentDataView, value: currentMetricValue)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _getCurrentViewColor(),
                            fontSize: isNarrow ? 11 : 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetricPill(
                      label: 'Farmers',
                      value: data.farmers.toString(),
                      color: const Color(0xFF1D4ED8),
                      isNarrow: isNarrow,
                    ),
                    _buildMetricPill(
                      label: 'Scans',
                      value: data.scans.toString(),
                      color: const Color(0xFF7E22CE),
                      isNarrow: isNarrow,
                    ),
                    _buildMetricPill(
                      label: 'Yield',
                      value: formatGeoMetricValue(
                        currentDataView: 'yield_revenue',
                        value: data.yieldRevenue,
                      ),
                      color: const Color(0xFF166534),
                      isNarrow: isNarrow,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flag_circle_rounded,
                      size: isNarrow ? 13 : 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Density: $densityLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: isNarrow ? 10 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Click to view details',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: isNarrow ? 10 : 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
    required bool isNarrow,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 8 : 9,
        vertical: isNarrow ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isNarrow ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: isNarrow ? 10 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCurrentViewColor() {
    switch (widget.currentDataView) {
      case 'farmers':
        return const Color(0xFF1D4ED8);
      case 'scans':
        return const Color(0xFF7E22CE);
      case 'yield_revenue':
        return const Color(0xFF166534);
      default:
        return Colors.grey;
    }
  }

  String _getCurrentViewName() {
    switch (widget.currentDataView) {
      case 'farmers':
        return 'Farmers Distribution';
      case 'scans':
        return 'Scan Activity';
      case 'yield_revenue':
        return 'Yield Revenue';
      default:
        return 'Metric';
    }
  }

  num _getCurrentViewValue(MapDataModel data) {
    switch (widget.currentDataView) {
      case 'farmers':
        return data.farmers;
      case 'scans':
        return data.scans;
      case 'yield_revenue':
        return data.yieldRevenue;
      default:
        return 0;
    }
  }
}