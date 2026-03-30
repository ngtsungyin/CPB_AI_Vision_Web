import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:cpbaivision_app/components/map_component.dart';
import 'package:cpbaivision_app/shared/models/map_data_model.dart';

class GeoMapSectionContainer extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? mapData;
  final MapShapeSource? mapSource;
  final List<MapDataModel> mapDataList;
  final List<num> metricValues;
  final String? selectedState;
  final String currentDataView;
  final String currentDataViewTitle;
  final ValueChanged<String> onStateSelected;
  final VoidCallback onClearSelection;

  const GeoMapSectionContainer({
    super.key,
    required this.isLoading,
    required this.mapData,
    required this.mapSource,
    required this.mapDataList,
    required this.metricValues,
    required this.selectedState,
    required this.currentDataView,
    required this.currentDataViewTitle,
    required this.onStateSelected,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 620;

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle(context),
                      const SizedBox(height: 10),
                      Text(
                        'Click a state to inspect detailed geographic metrics.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildHeaderTitle(context)),
                    const SizedBox(width: 12),
                    Text(
                      'Click a state to inspect metrics',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFF7F8FA),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (mapData == null || mapSource == null)
                          ? const _GeoMapErrorState()
                          : RepaintBoundary(
                              child: MapComponent(
                                mapSource: mapSource!,
                                mapDataList: mapDataList,
                                metricValues: metricValues,
                                onStateSelected: onStateSelected,
                                selectedState: selectedState,
                                currentDataView: currentDataView,
                              ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.map_rounded, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentDataViewTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                'Interactive choropleth map',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

class _GeoMapErrorState extends StatelessWidget {
  const _GeoMapErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load map data',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please verify the map asset configuration and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}