import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_maps/maps.dart';

import 'package:cpbaivision_app/features/geo/helpers/geo_view_helper.dart';
import 'package:cpbaivision_app/features/geo/services/geo_analytics_service.dart';
import 'package:cpbaivision_app/features/geo/widgets/geo_data_view_selector.dart';
import 'package:cpbaivision_app/features/geo/widgets/geo_map_and_legend_row.dart';
import 'package:cpbaivision_app/features/geo/widgets/geo_page_header.dart';
import 'package:cpbaivision_app/shared/models/map_data_model.dart';

class GeoViewPage extends StatefulWidget {
  const GeoViewPage({super.key});

  @override
  State<GeoViewPage> createState() => _GeoViewPageState();
}

class _GeoViewPageState extends State<GeoViewPage> {
  final GeoAnalyticsService _geoAnalyticsService = GeoAnalyticsService();

  Map<String, dynamic>? _mapData;
  String? _selectedState;
  Map<String, dynamic>? _selectedStateData;
  bool _isLoading = true;
  MapShapeSource? _mapSource;
  String _currentDataView = 'farmers';

  final List<MapDataModel> _mapDataList = [];
  Map<String, Map<String, dynamic>> _stateStatistics = {};

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      final loadedData = await rootBundle.loadString('assets/MYsimplemap.json');
      final jsonData = json.decode(loadedData);

      final liveStats = await _geoAnalyticsService.getStateStatistics();
      _stateStatistics = liveStats;

      _updateMapDataColors();
      final source = _createMapSource();

      if (!mounted) return;

      setState(() {
        _mapData = jsonData;
        _mapSource = source;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading map data: $e');

      if (!mounted) return;

      setState(() {
        _mapData = {'type': 'FeatureCollection', 'features': []};
        _mapSource = null;
        _isLoading = false;
      });
    }
  }

  void _updateMapDataColors() {
    _mapDataList.clear();

    _stateStatistics.forEach((stateName, data) {
      _mapDataList.add(
        MapDataModel(
          statename: stateName,
          farmers: (data['farmers'] ?? 0) as int,
          scans: (data['scans'] ?? 0) as int,
          yieldRevenue: ((data['yield_revenue'] ?? 0.0) as num).toDouble(),
          color: _getStateColor(stateName),
        ),
      );
    });
  }

  MapShapeSource _createMapSource() {
    return MapShapeSource.asset(
      'assets/MYsimplemap.json',
      shapeDataField: 'name',
      dataCount: _mapDataList.length,
      primaryValueMapper: (int index) => _mapDataList[index].statename,
      shapeColorValueMapper: (int index) => _mapDataList[index].color,
    );
  }

  Color _getStateColor(String stateName) {
    return getGeoStateColor(
      stateName: stateName,
      currentDataView: _currentDataView,
      stateStatistics: _stateStatistics,
    );
  }

  String _getDensityLevel(num value) {
    return getGeoDensityLevel(
      value: value,
      currentDataView: _currentDataView,
      metricValues: _currentMetricValues(),
    );
  }

  String _getCurrentDataViewTitle() {
    return getGeoCurrentDataViewTitle(_currentDataView);
  }

  List<num> _currentMetricValues() {
    switch (_currentDataView) {
      case 'farmers':
        return _mapDataList.map((e) => e.farmers).toList();
      case 'scans':
        return _mapDataList.map((e) => e.scans).toList();
      case 'yield_revenue':
        return _mapDataList.map((e) => e.yieldRevenue).toList();
      default:
        return const <num>[];
    }
  }

  void _onStateSelected(String stateName) {
    setState(() {
      _selectedState = stateName;
      final live = _stateStatistics[stateName];
      _selectedStateData =
          live == null ? null : Map<String, dynamic>.from(live);
    });
  }

  void _changeDataView(String newView) {
    setState(() {
      _currentDataView = newView;
      _updateMapDataColors();
      if (_mapData != null) {
        _mapSource = _createMapSource();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedState = null;
      _selectedStateData = null;
    });
  }

  Widget _buildTopSummaryCards() {
    int totalFarmers = 0;
    int totalScans = 0;
    double totalYieldRevenue = 0.0;

    for (final state in _stateStatistics.values) {
      totalFarmers += (state['farmers'] ?? 0) as int;
      totalScans += (state['scans'] ?? 0) as int;
      totalYieldRevenue += ((state['yield_revenue'] ?? 0.0) as num).toDouble();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final stacked = width < 900;

        final cards = [
          _SummaryCard(
            title: 'Farmers',
            value: formatGeoMetricValue(
              currentDataView: 'farmers',
              value: totalFarmers,
            ),
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF1D4ED8),
            subtitle: 'Unique farmer owners by state',
          ),
          _SummaryCard(
            title: 'Scans',
            value: formatGeoMetricValue(
              currentDataView: 'scans',
              value: totalScans,
            ),
            icon: Icons.document_scanner_rounded,
            color: const Color(0xFF7E22CE),
            subtitle: 'Recorded scan activity',
          ),
          _SummaryCard(
            title: 'Yield Revenue',
            value: formatGeoMetricValue(
              currentDataView: 'yield_revenue',
              value: totalYieldRevenue,
            ),
            icon: Icons.paid_rounded,
            color: const Color(0xFF166534),
            subtitle: 'Revenue from yield records',
          ),
        ];

        if (stacked) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
            const SizedBox(width: 14),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildSelectedStateOverview() {
    if (_selectedState == null || _selectedStateData == null) {
      return const SizedBox.shrink();
    }

    final farmers = (_selectedStateData!['farmers'] ?? 0) as int;
    final scans = (_selectedStateData!['scans'] ?? 0) as int;
    final yieldRevenue =
        ((_selectedStateData!['yield_revenue'] ?? 0.0) as num).toDouble();

    final currentMetricValue = _currentDataView == 'farmers'
        ? farmers
        : _currentDataView == 'scans'
            ? scans
            : yieldRevenue;

    final densityLevel = _getDensityLevel(currentMetricValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 900;

          final primary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected State Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Detailed live metrics for $_selectedState.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              _MetricTile(
                label: 'Farmers',
                value: formatGeoMetricValue(
                  currentDataView: 'farmers',
                  value: farmers,
                ),
                color: const Color(0xFF1D4ED8),
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'Scans',
                value: formatGeoMetricValue(
                  currentDataView: 'scans',
                  value: scans,
                ),
                color: const Color(0xFF7E22CE),
                icon: Icons.document_scanner_rounded,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'Yield Revenue',
                value: formatGeoMetricValue(
                  currentDataView: 'yield_revenue',
                  value: yieldRevenue,
                ),
                color: const Color(0xFF166534),
                icon: Icons.paid_rounded,
              ),
            ],
          );

          final derived = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Derived Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'State-specific context based on the active metric.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              _InfoTile(label: 'Selected State', value: _selectedState!),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Current Metric View',
                value: _getCurrentDataViewTitle(),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Density Level',
                value: densityLevel,
                valueColor: _getStateColor(_selectedState!),
              ),
              const SizedBox(height: 12),
              const _InfoTile(
                label: 'Status',
                value: 'Focused state analysis active',
              ),
            ],
          );

          if (stacked) {
            return Column(
              children: [
                primary,
                const SizedBox(height: 18),
                derived,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: primary),
              const SizedBox(width: 18),
              Expanded(child: derived),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metricValues = _currentMetricValues();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GeoPageHeader(
              currentMetricLabel: _getCurrentDataViewTitle(),
              selectedState: _selectedState,
            ),
            const SizedBox(height: 20),
            _buildTopSummaryCards(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: GeoDataViewSelector(
                currentDataView: _currentDataView,
                onChanged: _changeDataView,
              ),
            ),
            const SizedBox(height: 16),
            GeoMapAndLegendRow(
              isLoading: _isLoading,
              mapData: _mapData,
              mapSource: _mapSource,
              mapDataList: _mapDataList,
              metricValues: metricValues,
              selectedState: _selectedState,
              selectedStateData: _selectedStateData,
              currentDataView: _currentDataView,
              currentDataViewTitle: _getCurrentDataViewTitle(),
              onStateSelected: _onStateSelected,
              onClearSelection: _clearSelection,
            ),
            if (_selectedState != null && _selectedStateData != null) ...[
              const SizedBox(height: 20),
              _buildSelectedStateOverview(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? Colors.black87,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}