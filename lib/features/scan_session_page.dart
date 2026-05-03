import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/core/widgets/admin_table.dart';

class ScanSessionPage extends StatefulWidget {
  const ScanSessionPage({super.key});

  @override
  State<ScanSessionPage> createState() => _ScanSessionPageState();
}

class _ScanSessionPageState extends State<ScanSessionPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  bool isLoading = true;
  String searchQuery = '';
  String selectedDecision = 'All';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  String _safeDate(dynamic value) {
    if (value == null) return '-';
    final text = value.toString();
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  String _farmerName(dynamic item) {
    final farmer = item['farmer'];
    if (farmer == null) return '-';

    final first = farmer['firstname'] ?? '';
    final last = farmer['lastname'] ?? '';
    final fullName = '$first $last'.trim();

    return fullName.isEmpty ? '-' : fullName;
  }

  String _farmName(dynamic item) {
    return item['farm']?['farmname']?.toString() ?? '-';
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase.from('scan_sessions').select('''
            *,
            farmer:users!scan_sessions_farmerid_fkey(
              firstname,
              lastname,
              email
            ),
            farm:farms!scan_sessions_farmid_fkey(
              farmname,
              state,
              district,
              village,
              latitude,
              longitude
            )
          ''').order('sessiondate', ascending: false);

      debugPrint('Scan sessions count: ${response.length}');
      debugPrint('Scan sessions data: $response');

      data = response;
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching scan sessions: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scan sessions: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchQuery.toLowerCase();

    filteredData = data.where((item) {
      final farmer = _farmerName(item).toLowerCase();
      final farm = _farmName(item).toLowerCase();
      final decision = _safeText(item['finaldecision']);

      final matchesSearch = farmer.contains(query) ||
          farm.contains(query) ||
          decision.toLowerCase().contains(query);

      final matchesDecision =
          selectedDecision == 'All' || decision == selectedDecision;

      return matchesSearch && matchesDecision;
    }).toList();
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void onDecisionChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedDecision = value;
      _applyFilters();
    });
  }

  Color _decisionColor(String decision) {
    final normalized = decision.toLowerCase();

    if (normalized.contains('spray') || normalized.contains('high')) {
      return const Color(0xFFDC2626);
    }

    if (normalized.contains('monitor') || normalized.contains('medium')) {
      return const Color(0xFFD97706);
    }

    if (normalized.contains('safe') || normalized.contains('low')) {
      return const Color(0xFF059669);
    }

    return const Color(0xFF4B5563);
  }

  Widget _decisionBadge(dynamic value) {
    final decision = _safeText(value);
    final color = _decisionColor(decision);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        decision,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _completedBadge(dynamic value) {
    final completed = value == true;
    final color = completed ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        completed ? 'Completed' : 'Pending',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildHeader() {
  final decisions = <String>{
    'All',
    ...data.map((item) => _safeText(item['finaldecision'])),
  }.toList();

  if (!decisions.contains(selectedDecision)) {
    selectedDecision = 'All';
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final searchBox = SizedBox(
          width: isCompact ? double.infinity : 270,
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search farmer / farm / decision...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),
        );

        final decisionFilter = SizedBox(
          width: isCompact ? double.infinity : 190,
          child: DropdownButtonFormField<String>(
            value: selectedDecision,
            isExpanded: true,
            items: decisions.map((decision) {
              return DropdownMenuItem<String>(
                value: decision,
                child: Text(
                  decision,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: onDecisionChanged,
            decoration: InputDecoration(
              labelText: 'Decision',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),
        );

        final refreshButton = ElevatedButton.icon(
          onPressed: fetchData,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Session Records',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              searchBox,
              const SizedBox(height: 10),
              decisionFilter,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: refreshButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            const Text(
              'Scan Session Records',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            searchBox,
            const SizedBox(width: 12),
            decisionFilter,
            const SizedBox(width: 12),
            refreshButton,
          ],
        );
      },
    ),
  );
}

  Widget buildTable() {
    return AdminTable(
      isLoading: isLoading,
      columns: const [
        DataColumn(label: Text('Farmer')),
        DataColumn(label: Text('Farm')),
        DataColumn(label: Text('Total Eggs')),
        DataColumn(label: Text('Average Eggs')),
        DataColumn(label: Text('Decision')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Action')),
      ],
      rows: filteredData.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(_farmerName(item))),
            DataCell(Text(_farmName(item))),
            DataCell(Text(_safeText(item['totaleggs']))),
            DataCell(Text(_safeText(item['averageeggs']))),
            DataCell(_decisionBadge(item['finaldecision'])),
            DataCell(_completedBadge(item['completed'])),
            DataCell(Text(_safeDate(item['sessiondate']))),
            DataCell(
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View session scans',
                onPressed: () => showSessionDetails(item),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Future<List<dynamic>> fetchScansBySession(String sessionId) async {
    try {
      final response = await supabase
          .from('scans')
          .select('''
            scanid,
            farmerid,
            farmid,
            imageurl,
            imagepath,
            eggsdetected,
            confidencescore,
            scandate,
            gpslocation,
            sessionid
          ''')
          .eq('sessionid', sessionId)
          .order('scandate', ascending: true);

      debugPrint('Scans for session $sessionId count: ${response.length}');
      debugPrint('Scans for session $sessionId data: $response');

      return response;
    } catch (e) {
      debugPrint('Error fetching scans by session: $e');
      rethrow;
    }
  }

  void showSessionDetails(dynamic session) {
    final sessionId = _safeText(session['sessionid']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Scan Session Details'),
          content: SizedBox(
            width: 900,
            height: 620,
            child: FutureBuilder<List<dynamic>>(
              future: fetchScansBySession(sessionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Failed to load scans: ${snapshot.error}');
                }

                final scans = snapshot.data ?? [];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Session Summary'),
                      _detailRow('Farmer', _farmerName(session)),
                      _detailRow('Email', _safeText(session['farmer']?['email'])),
                      _detailRow('Farm', _farmName(session)),
                      _detailRow('State', _safeText(session['farm']?['state'])),
                      _detailRow(
                        'District',
                        _safeText(session['farm']?['district']),
                      ),
                      _detailRow(
                        'Village',
                        _safeText(session['farm']?['village']),
                      ),
                      _detailRow('Total Eggs', _safeText(session['totaleggs'])),
                      _detailRow(
                        'Average Eggs',
                        _safeText(session['averageeggs']),
                      ),
                      _detailRow(
                        'Cumulative Eggs',
                        _safeText(session['cumulativeeggs']),
                      ),
                      _detailRow(
                        'Final Decision',
                        _safeText(session['finaldecision']),
                      ),
                      _detailRow(
                        'Recommendation',
                        _safeText(session['recommendationreason']),
                      ),
                      _detailRow(
                        'Session Date',
                        _safeDate(session['sessiondate']),
                      ),
                      _detailRow(
                        'Farm GPS',
                        '${_safeText(session['farm']?['latitude'])}, ${_safeText(session['farm']?['longitude'])}',
                      ),

                      const SizedBox(height: 20),
                      _sectionTitle('Related Scan Images & GPS'),

                      if (scans.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'No scan images found for this session.',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: scans.map((scan) {
                            return _scanCard(scan);
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _scanCard(dynamic scan) {
    final imageUrl = _safeText(scan['imageurl']);
    final gps = scan['gpslocation'];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 155,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: imageUrl == '-' || imageUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFF6B7280),
                    ),
                  )
                : ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _miniDetail('Eggs Detected', _safeText(scan['eggsdetected'])),
                _miniDetail('Confidence', _safeText(scan['confidencescore'])),
                _miniDetail('Scan Date', _safeDate(scan['scandate'])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showImageModal(scan),
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: const Text('Image'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showGpsModal(gps),
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text('GPS'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showImageModal(dynamic scan) {
    final imageUrl = _safeText(scan['imageurl']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Scan Image'),
          content: SizedBox(
            width: 620,
            height: 520,
            child: imageUrl == '-' || imageUrl.isEmpty
                ? const Center(child: Text('No image URL available.'))
                : Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Text('Unable to load image.'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showGpsModal(dynamic gps) {
    final gpsText = _formatGps(gps);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Scan GPS Location'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 48,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  gpsText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Copy the coordinates above and paste them into Google Maps if needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatGps(dynamic gps) {
    if (gps == null) return 'No GPS data available.';

    if (gps is Map) {
      final lat = gps['latitude'] ?? gps['lat'];
      final lng = gps['longitude'] ?? gps['lng'] ?? gps['lon'];

      if (lat != null && lng != null) {
        return '$lat, $lng';
      }

      return gps.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }

    return gps.toString();
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        buildTable(),
      ],
    );
  }
}