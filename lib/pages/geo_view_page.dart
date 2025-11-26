// pages/geo_view_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:syncfusion_flutter_maps/maps.dart';

// Import components
import '../components/map_component.dart';
import '../components/legend_component.dart';
import '../components/state_details_component.dart';
import '../components/state_statistics_component.dart';
import '../models/map_data_model.dart';

class GeoViewPage extends StatefulWidget {
  const GeoViewPage({super.key});

  @override
  State<GeoViewPage> createState() => _GeoViewPageState();
}

class _GeoViewPageState extends State<GeoViewPage> {
  Map<String, dynamic>? _mapData;
  String? _selectedState;
  Map<String, dynamic>? _selectedStateData;
  bool _isLoading = true;
  late MapShapeSource _mapSource;

  // Add data view state
  String _currentDataView = 'farmers'; // 'farmers', 'scans', 'sprays'

  // Enhanced mock data with more statistics
  final Map<String, Map<String, dynamic>> _stateStatistics = {
    'Johor': {
      'farmers': 245, 
      'scans': 1567, 
      'sprays': 892,
      'active_farms': 198,
      'crop_yield': 3456,
      'revenue': 2345678,
      'growth_rate': 12.5,
      'last_updated': '2024-01-15',
    },
    'Kedah': {
      'farmers': 189, 
      'scans': 1234, 
      'sprays': 645,
      'active_farms': 156,
      'crop_yield': 2876,
      'revenue': 1876543,
      'growth_rate': 8.3,
      'last_updated': '2024-01-14',
    },
    'Kelantan': {
      'farmers': 167, 
      'scans': 987, 
      'sprays': 543,
      'active_farms': 134,
      'crop_yield': 2345,
      'revenue': 1567890,
      'growth_rate': 6.7,
      'last_updated': '2024-01-13',
    },
    'Melaka': {
      'farmers': 98, 
      'scans': 654, 
      'sprays': 321,
      'active_farms': 76,
      'crop_yield': 1456,
      'revenue': 987654,
      'growth_rate': 15.2,
      'last_updated': '2024-01-15',
    },
    'Negeri Sembilan': {
      'farmers': 134, 
      'scans': 876, 
      'sprays': 432,
      'active_farms': 112,
      'crop_yield': 1987,
      'revenue': 1234567,
      'growth_rate': 9.8,
      'last_updated': '2024-01-14',
    },
    'Pahang': {
      'farmers': 278, 
      'scans': 1876, 
      'sprays': 987,
      'active_farms': 234,
      'crop_yield': 3987,
      'revenue': 2876543,
      'growth_rate': 11.4,
      'last_updated': '2024-01-15',
    },
    'Perak': {
      'farmers': 312, 
      'scans': 2345, 
      'sprays': 1234,
      'active_farms': 278,
      'crop_yield': 4567,
      'revenue': 3456789,
      'growth_rate': 14.2,
      'last_updated': '2024-01-15',
    },
    'Perlis': {
      'farmers': 45, 
      'scans': 321, 
      'sprays': 187,
      'active_farms': 38,
      'crop_yield': 876,
      'revenue': 543210,
      'growth_rate': 5.6,
      'last_updated': '2024-01-13',
    },
    'Pulau Pinang': {
      'farmers': 156, 
      'scans': 1098, 
      'sprays': 654,
      'active_farms': 134,
      'crop_yield': 2345,
      'revenue': 1678901,
      'growth_rate': 10.3,
      'last_updated': '2024-01-14',
    },
    'Sabah': {
      'farmers': 423, 
      'scans': 2987, 
      'sprays': 1543,
      'active_farms': 387,
      'crop_yield': 5678,
      'revenue': 3987654,
      'growth_rate': 16.8,
      'last_updated': '2024-01-15',
    },
    'Sarawak': {
      'farmers': 387, 
      'scans': 2654, 
      'sprays': 1432,
      'active_farms': 345,
      'crop_yield': 4876,
      'revenue': 3567890,
      'growth_rate': 13.7,
      'last_updated': '2024-01-15',
    },
    'Selangor': {
      'farmers': 298, 
      'scans': 1987, 
      'sprays': 1098,
      'active_farms': 265,
      'crop_yield': 3765,
      'revenue': 2876543,
      'growth_rate': 12.1,
      'last_updated': '2024-01-15',
    },
    'Terengganu': {
      'farmers': 123, 
      'scans': 765, 
      'sprays': 432,
      'active_farms': 98,
      'crop_yield': 1876,
      'revenue': 1345678,
      'growth_rate': 7.9,
      'last_updated': '2024-01-14',
    },
    'Kuala Lumpur': {
      'farmers': 67, 
      'scans': 432, 
      'sprays': 234,
      'active_farms': 45,
      'crop_yield': 987,
      'revenue': 765432,
      'growth_rate': 18.2,
      'last_updated': '2024-01-15',
    },
    'Labuan': {
      'farmers': 23, 
      'scans': 156, 
      'sprays': 87,
      'active_farms': 18,
      'crop_yield': 456,
      'revenue': 321098,
      'growth_rate': 4.3,
      'last_updated': '2024-01-13',
    },
    'Putrajaya': {
      'farmers': 12, 
      'scans': 87, 
      'sprays': 43,
      'active_farms': 9,
      'crop_yield': 234,
      'revenue': 198765,
      'growth_rate': 22.1,
      'last_updated': '2024-01-15',
    },
  };

  final List<MapDataModel> _mapDataList = [];

  @override
  void initState() {
    super.initState();
    _initializeMapData();
    _loadMapData();
  }

  void _initializeMapData() {
    _updateMapDataColors();
  }

  void _updateMapDataColors() {
    _mapDataList.clear();
    _stateStatistics.forEach((stateName, data) {
      _mapDataList.add(MapDataModel(
        statename: stateName,
        farmers: data['farmers'],
        scans: data['scans'],
        sprays: data['sprays'],
        color: _getStateColor(stateName),
      ));
    });
  }

  Future<void> _loadMapData() async {
    try {
      setState(() => _isLoading = true);

      final String loadedData = await rootBundle.loadString('assets/MYsimplemap.json');
      final jsonData = json.decode(loadedData);

      _mapSource = MapShapeSource.asset(
        'assets/MYsimplemap.json',
        shapeDataField: 'name',
        dataCount: _mapDataList.length,
        primaryValueMapper: (int index) => _mapDataList[index].statename,
        shapeColorValueMapper: (int index) => _mapDataList[index].color,
      );

      setState(() {
        _mapData = jsonData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading map data: $e');
      setState(() {
        _mapData = {'type': 'FeatureCollection', 'features': []};
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map data not found. Using demo mode.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Color _getStateColor(String stateName) {
    final stats = _stateStatistics[stateName];
    if (stats == null) return Colors.grey[300]!;

    final value = stats[_currentDataView] ?? 0;
    
    // Different color scales for different data views
    switch (_currentDataView) {
      case 'farmers':
        if (value > 300) return Colors.red[700]!;
        if (value > 200) return Colors.orange[700]!;
        if (value > 100) return Colors.yellow[700]!;
        if (value > 50) return Colors.green[700]!;
        return Colors.blue[700]!;
      
      case 'scans':
        if (value > 2000) return Colors.purple[800]!;
        if (value > 1500) return Colors.purple[600]!;
        if (value > 1000) return Colors.purple[400]!;
        if (value > 500) return Colors.purple[300]!;
        return Colors.purple[200]!;
      
      case 'sprays':
        if (value > 1000) return Colors.teal[800]!;
        if (value > 750) return Colors.teal[600]!;
        if (value > 500) return Colors.teal[400]!;
        if (value > 250) return Colors.teal[300]!;
        return Colors.teal[200]!;
      
      default:
        return Colors.grey[300]!;
    }
  }

  void _onStateSelected(String stateName) {
    setState(() {
      _selectedState = stateName;
      _selectedStateData = _stateStatistics[stateName];
    });
  }

  void _changeDataView(String newView) {
    setState(() {
      _currentDataView = newView;
      _updateMapDataColors();
      // Reload map source with new colors
      _mapSource = MapShapeSource.asset(
        'assets/MYsimplemap.json',
        shapeDataField: 'name',
        dataCount: _mapDataList.length,
        primaryValueMapper: (int index) => _mapDataList[index].statename,
        shapeColorValueMapper: (int index) => _mapDataList[index].color,
      );
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedState = null;
      _selectedStateData = null;
    });
  }

  String _getDensityLevel(int value) {
    switch (_currentDataView) {
      case 'farmers':
        if (value > 300) return 'Very High';
        if (value > 200) return 'High';
        if (value > 100) return 'Medium';
        if (value > 50) return 'Low';
        return 'Very Low';
      
      case 'scans':
        if (value > 2000) return 'Very High';
        if (value > 1500) return 'High';
        if (value > 1000) return 'Medium';
        if (value > 500) return 'Low';
        return 'Very Low';
      
      case 'sprays':
        if (value > 1000) return 'Very High';
        if (value > 750) return 'High';
        if (value > 500) return 'Medium';
        if (value > 250) return 'Low';
        return 'Very Low';
      
      default:
        return 'Unknown';
    }
  }

  String _getCurrentDataViewTitle() {
    switch (_currentDataView) {
      case 'farmers': return 'Farmers Distribution';
      case 'scans': return 'Scan Activity';
      case 'sprays': return 'Spray Activity';
      default: return 'Malaysia Map';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              _buildPageHeader(),
              const SizedBox(height: 24),

              // Data View Selector
              _buildDataViewSelector(),
              const SizedBox(height: 16),

              // Main Content - Scrollable when state is selected
              Expanded(
                child: _selectedState != null 
                    ? _buildScrollableContent()
                    : _buildMapAndLegendRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map and Legend Row
          _buildMapAndLegendRow(),
          
          // State Details Section
          const SizedBox(height: 24),
          StateDetailsComponent(
            selectedState: _selectedState!,
            selectedStateData: _selectedStateData!,
            getStateColor: _getStateColor,
            getDensityLevel: _getDensityLevel,
            currentDataView: _currentDataView,
            onClearSelection: _clearSelection,
          ),
          
          // Enhanced Statistics Section
          const SizedBox(height: 24),
          StateStatisticsComponent(
            stateName: _selectedState!,
            stateData: _selectedStateData!,
            currentDataView: _currentDataView,
          ),
          
          // Add some bottom padding for better scrolling
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMapAndLegendRow() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 400, // Minimum height for map section
        maxHeight: 600, // Maximum height for map section
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: _buildMapSection(),
          ),
          const SizedBox(width: 24),

          // Legend Section
          Expanded(
            flex: 1,
            child: _buildLegendSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geo View',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Interactive map showing farm distributions and activity across Malaysian states. Click on any state to view detailed statistics.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDataViewSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.layers, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text(
            'View:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          ..._buildDataViewButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildDataViewButtons() {
    final views = [
      {'key': 'farmers', 'label': 'Farmers'},
      {'key': 'scans', 'label': 'Scans'},
      {'key': 'sprays', 'label': 'Sprays'},
    ];

    return views.map((view) {
      final isActive = _currentDataView == view['key'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(view['label']!),
          selected: isActive,
          onSelected: (selected) => _changeDataView(view['key']!),
          selectedColor: Colors.blue,
          labelStyle: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMapSection() {
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
          // Map Header
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
                const Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _getCurrentDataViewTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedState != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Selected: $_selectedState',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _clearSelection,
                          child: const Icon(Icons.close, size: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Map Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mapData == null
                    ? _buildErrorState()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        child: MapComponent(
                          mapSource: _mapSource,
                          mapDataList: _mapDataList,
                          onStateSelected: _onStateSelected,
                          selectedState: _selectedState,
                          currentDataView: _currentDataView,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSection() {
    return LegendComponent(
      selectedState: _selectedState,
      selectedStateData: _selectedStateData,
      getStateColor: _getStateColor,
      getDensityLevel: _getDensityLevel,
      currentDataView: _currentDataView,
      onClearSelection: _clearSelection,
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Unable to load map data',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}