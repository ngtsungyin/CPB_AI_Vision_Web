import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import 'package:cpbaivision_app/components/legend_component.dart';
import 'package:cpbaivision_app/features/geo/widgets/geo_map_section_container.dart';
import 'package:cpbaivision_app/shared/models/map_data_model.dart';

class GeoMapAndLegendRow extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? mapData;
  final MapShapeSource? mapSource;
  final List<MapDataModel> mapDataList;
  final List<num> metricValues;
  final String? selectedState;
  final Map<String, dynamic>? selectedStateData;
  final String currentDataView;
  final String currentDataViewTitle;
  final ValueChanged<String> onStateSelected;
  final VoidCallback onClearSelection;

  const GeoMapAndLegendRow({
    super.key,
    required this.isLoading,
    required this.mapData,
    required this.mapSource,
    required this.mapDataList,
    required this.metricValues,
    required this.selectedState,
    required this.selectedStateData,
    required this.currentDataView,
    required this.currentDataViewTitle,
    required this.onStateSelected,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isStacked = width < 1100;

        if (isStacked) {
          return Column(
            children: [
              SizedBox(
                height: width < 520 ? 380 : 460,
                child: GeoMapSectionContainer(
                  isLoading: isLoading,
                  mapData: mapData,
                  mapSource: mapSource,
                  mapDataList: mapDataList,
                  metricValues: metricValues,
                  selectedState: selectedState,
                  currentDataView: currentDataView,
                  currentDataViewTitle: currentDataViewTitle,
                  onStateSelected: onStateSelected,
                  onClearSelection: onClearSelection,
                ),
              ),
              const SizedBox(height: 16),
              _LegendCardShell(
                child: SizedBox(
                  height: 320,
                  child: LegendComponent(
                    selectedState: selectedState,
                    selectedStateData: selectedStateData,
                    metricValues: metricValues,
                    currentDataView: currentDataView,
                    onClearSelection: onClearSelection,
                  ),
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 560,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: GeoMapSectionContainer(
                  isLoading: isLoading,
                  mapData: mapData,
                  mapSource: mapSource,
                  mapDataList: mapDataList,
                  metricValues: metricValues,
                  selectedState: selectedState,
                  currentDataView: currentDataView,
                  currentDataViewTitle: currentDataViewTitle,
                  onStateSelected: onStateSelected,
                  onClearSelection: onClearSelection,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: _LegendCardShell(
                  child: LegendComponent(
                    selectedState: selectedState,
                    selectedStateData: selectedStateData,
                    metricValues: metricValues,
                    currentDataView: currentDataView,
                    onClearSelection: onClearSelection,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendCardShell extends StatelessWidget {
  final Widget child;

  const _LegendCardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}