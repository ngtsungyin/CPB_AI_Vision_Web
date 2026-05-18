import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ai_analytics_service.dart';

class AiAnalyticsPage extends StatefulWidget {
  const AiAnalyticsPage({super.key});

  @override
  State<AiAnalyticsPage> createState() => _AiAnalyticsPageState();
}

class _AiAnalyticsPageState extends State<AiAnalyticsPage> {
  final service = AiAnalyticsService(Supabase.instance.client);
  final searchController = TextEditingController();

  bool isLoading = true;
  String selectedConfidence = 'All';

  List<Map<String, dynamic>> rawScans = [];
  List<Map<String, dynamic>> filteredScans = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    setState(() => isLoading = true);

    try {
      final result = await service.fetchAiAnalyticsData();

      rawScans = result;
      _applyFilters();
    } catch (e) {
      debugPrint('Failed to fetch AI analytics: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load AI analytics: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    filteredScans = rawScans.where((scan) {
      final farm = _farmName(scan).toLowerCase();
      final farmer = _farmerName(scan).toLowerCase();
      final state = _safeText(scan['farm']?['state']).toLowerCase();
      final district = _safeText(scan['farm']?['district']).toLowerCase();
      final confidence = _confidenceValue(scan);

      final matchesSearch = query.isEmpty ||
          farm.contains(query) ||
          farmer.contains(query) ||
          state.contains(query) ||
          district.contains(query);

      final matchesConfidence = selectedConfidence == 'All' ||
          _confidenceLabel(confidence) == selectedConfidence;

      return matchesSearch && matchesConfidence;
    }).toList();
  }

  AiAnalyticsSummary get summary {
    return AiAnalyticsSummary.fromScans(filteredScans);
  }

  List<FarmDetectionSummary> get farmSummaries {
    final map = <String, FarmDetectionSummary>{};

    for (final scan in filteredScans) {
      final farmName = _farmName(scan);
      final current = map[farmName] ??
          FarmDetectionSummary(
            farmName: farmName,
            scanCount: 0,
            totalEggs: 0,
            totalBoxes: 0,
            confidenceTotal: 0,
            confidenceCount: 0,
          );

      final eggs = _intValue(scan['eggsdetected']);
      final confidence = _confidenceValue(scan);
      final images = _scanImages(scan);
      final boxes = images.fold<int>(
        0,
        (sum, image) => sum + _boxesCount(image['boxes']),
      );

      map[farmName] = current.copyWith(
        scanCount: current.scanCount + 1,
        totalEggs: current.totalEggs + eggs,
        totalBoxes: current.totalBoxes + boxes,
        confidenceTotal: current.confidenceTotal + confidence,
        confidenceCount: current.confidenceCount + 1,
      );
    }

    final list = map.values.toList();
    list.sort((a, b) => b.totalBoxes.compareTo(a.totalBoxes));

    return list;
  }

  List<Map<String, dynamic>> get lowConfidenceScans {
    final items = filteredScans.where((scan) {
      return _confidenceValue(scan) < 0.50;
    }).toList();

    items.sort((a, b) {
      return _confidenceValue(a).compareTo(_confidenceValue(b));
    });

    return items.take(10).toList();
  }

  void handleSearch(String value) {
    setState(_applyFilters);
  }

  void handleConfidenceChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedConfidence = value;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = summary;
    final farms = farmSummaries;

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageHeader(),
          const SizedBox(height: 24),
          _FilterSection(
            controller: searchController,
            selectedConfidence: selectedConfidence,
            onSearch: handleSearch,
            onConfidenceChanged: handleConfidenceChanged,
            onRefresh: fetch,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetch,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryGrid(summary: analytics),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 1050;

                              if (isCompact) {
                                return Column(
                                  children: [
                                    _ConfidenceDistributionCard(
                                      summary: analytics,
                                    ),
                                    const SizedBox(height: 18),
                                    _BoundingBoxAnalyticsCard(
                                      summary: analytics,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _ConfidenceDistributionCard(
                                      summary: analytics,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _BoundingBoxAnalyticsCard(
                                      summary: analytics,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 1050;

                              if (isCompact) {
                                return Column(
                                  children: [
                                    _FarmDetectionRankingCard(farms: farms),
                                    const SizedBox(height: 18),
                                    _LowConfidenceReviewCard(
                                      scans: lowConfidenceScans,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child:
                                        _FarmDetectionRankingCard(farms: farms),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _LowConfidenceReviewCard(
                                      scans: lowConfidenceScans,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _ScanImageReviewTable(scans: filteredScans),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AiAnalyticsSummary {
  final int totalScans;
  final int totalImages;
  final int totalBoxes;
  final int noBoxImages;
  final int highConfidence;
  final int mediumConfidence;
  final int lowConfidence;
  final double averageConfidence;
  final double averageBoxesPerImage;
  final double averageBoxArea;

  const AiAnalyticsSummary({
    required this.totalScans,
    required this.totalImages,
    required this.totalBoxes,
    required this.noBoxImages,
    required this.highConfidence,
    required this.mediumConfidence,
    required this.lowConfidence,
    required this.averageConfidence,
    required this.averageBoxesPerImage,
    required this.averageBoxArea,
  });

  factory AiAnalyticsSummary.fromScans(List<Map<String, dynamic>> scans) {
    int totalImages = 0;
    int totalBoxes = 0;
    int noBoxImages = 0;
    int highConfidence = 0;
    int mediumConfidence = 0;
    int lowConfidence = 0;

    double confidenceTotal = 0;
    int confidenceCount = 0;

    double boxAreaTotal = 0;
    int boxAreaCount = 0;

    for (final scan in scans) {
      final confidence = _confidenceValue(scan);

      if (confidence > 0) {
        confidenceTotal += confidence;
        confidenceCount++;

        if (confidence >= 0.80) {
          highConfidence++;
        } else if (confidence >= 0.50) {
          mediumConfidence++;
        } else {
          lowConfidence++;
        }
      }

      final images = _scanImages(scan);
      totalImages += images.length;

      for (final image in images) {
        final boxes = _parseBoxes(image['boxes']);

        totalBoxes += boxes.length;

        if (boxes.isEmpty) {
          noBoxImages++;
        }

        for (final box in boxes) {
          final width = (box.x2 - box.x1).abs();
          final height = (box.y2 - box.y1).abs();
          final area = width * height;

          if (area > 0) {
            boxAreaTotal += area;
            boxAreaCount++;
          }
        }
      }
    }

    return AiAnalyticsSummary(
      totalScans: scans.length,
      totalImages: totalImages,
      totalBoxes: totalBoxes,
      noBoxImages: noBoxImages,
      highConfidence: highConfidence,
      mediumConfidence: mediumConfidence,
      lowConfidence: lowConfidence,
      averageConfidence:
          confidenceCount == 0 ? 0 : confidenceTotal / confidenceCount,
      averageBoxesPerImage:
          totalImages == 0 ? 0 : totalBoxes / totalImages,
      averageBoxArea: boxAreaCount == 0 ? 0 : boxAreaTotal / boxAreaCount,
    );
  }
}

class FarmDetectionSummary {
  final String farmName;
  final int scanCount;
  final int totalEggs;
  final int totalBoxes;
  final double confidenceTotal;
  final int confidenceCount;

  const FarmDetectionSummary({
    required this.farmName,
    required this.scanCount,
    required this.totalEggs,
    required this.totalBoxes,
    required this.confidenceTotal,
    required this.confidenceCount,
  });

  double get averageConfidence {
    if (confidenceCount == 0) return 0;
    return confidenceTotal / confidenceCount;
  }

  FarmDetectionSummary copyWith({
    String? farmName,
    int? scanCount,
    int? totalEggs,
    int? totalBoxes,
    double? confidenceTotal,
    int? confidenceCount,
  }) {
    return FarmDetectionSummary(
      farmName: farmName ?? this.farmName,
      scanCount: scanCount ?? this.scanCount,
      totalEggs: totalEggs ?? this.totalEggs,
      totalBoxes: totalBoxes ?? this.totalBoxes,
      confidenceTotal: confidenceTotal ?? this.confidenceTotal,
      confidenceCount: confidenceCount ?? this.confidenceCount,
    );
  }
}

class DetectionBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const DetectionBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Detection Analytics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Analyze model confidence, detection volume, bounding box patterns, and low-confidence scans that may require review.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  final TextEditingController controller;
  final String selectedConfidence;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onConfidenceChanged;
  final VoidCallback onRefresh;

  const _FilterSection({
    required this.controller,
    required this.selectedConfidence,
    required this.onSearch,
    required this.onConfidenceChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const confidenceValues = [
      'All',
      'High',
      'Medium',
      'Low',
    ];

    final safeValue = confidenceValues.contains(selectedConfidence)
        ? selectedConfidence
        : 'All';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;

          final search = TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search by farmer, farm, state, or district...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );

          final filter = DropdownButtonFormField<String>(
            value: safeValue,
            isExpanded: true,
            items: confidenceValues.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onConfidenceChanged,
            decoration: InputDecoration(
              labelText: 'Confidence Level',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          );

          final refresh = ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 12),
                filter,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: refresh,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              SizedBox(width: 220, child: filter),
              const SizedBox(width: 12),
              refresh,
            ],
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final AiAnalyticsSummary summary;

  const _SummaryGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final cards = [
          _MetricCard(
            title: 'Average Confidence',
            value: _percent(summary.averageConfidence),
            icon: Icons.psychology_alt_outlined,
            color: const Color(0xFF2563EB),
            subtitle: 'Mean confidence across scans',
          ),
          _MetricCard(
            title: 'Total AI Boxes',
            value: summary.totalBoxes.toString(),
            icon: Icons.center_focus_strong_outlined,
            color: const Color(0xFF16A34A),
            subtitle: 'Detected egg bounding boxes',
          ),
          _MetricCard(
            title: 'Scan Images',
            value: summary.totalImages.toString(),
            icon: Icons.image_outlined,
            color: const Color(0xFF9333EA),
            subtitle: 'Images linked to scan records',
          ),
          _MetricCard(
            title: 'Needs Review',
            value: summary.lowConfidence.toString(),
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFDC2626),
            subtitle: 'Low-confidence scan results',
          ),
        ];

        if (isCompact) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 138),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
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

class _ConfidenceDistributionCard extends StatelessWidget {
  final AiAnalyticsSummary summary;

  const _ConfidenceDistributionCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.highConfidence +
        summary.mediumConfidence +
        summary.lowConfidence;

    return _AnalyticsCard(
      title: 'Confidence Distribution',
      subtitle: 'Confidence categories across scan records',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          _DistributionRow(
            label: 'High Confidence',
            value: summary.highConfidence,
            total: total,
            color: const Color(0xFF16A34A),
            helper: '≥ 80%',
          ),
          const SizedBox(height: 14),
          _DistributionRow(
            label: 'Medium Confidence',
            value: summary.mediumConfidence,
            total: total,
            color: const Color(0xFFD97706),
            helper: '50% - 79%',
          ),
          const SizedBox(height: 14),
          _DistributionRow(
            label: 'Low Confidence',
            value: summary.lowConfidence,
            total: total,
            color: const Color(0xFFDC2626),
            helper: '< 50%',
          ),
        ],
      ),
    );
  }
}

class _BoundingBoxAnalyticsCard extends StatelessWidget {
  final AiAnalyticsSummary summary;

  const _BoundingBoxAnalyticsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Bounding Box Analytics',
      subtitle: 'Detection quantity and box-size patterns',
      icon: Icons.center_focus_strong_outlined,
      child: Column(
        children: [
          _CompactStatRow(
            label: 'Total bounding boxes',
            value: summary.totalBoxes.toString(),
          ),
          _CompactStatRow(
            label: 'Average boxes / image',
            value: summary.averageBoxesPerImage.toStringAsFixed(2),
          ),
          _CompactStatRow(
            label: 'Images with no boxes',
            value: summary.noBoxImages.toString(),
          ),
          _CompactStatRow(
            label: 'Average normalized box area',
            value: summary.averageBoxArea.toStringAsFixed(4),
          ),
        ],
      ),
    );
  }
}

class _FarmDetectionRankingCard extends StatelessWidget {
  final List<FarmDetectionSummary> farms;

  const _FarmDetectionRankingCard({required this.farms});

  @override
  Widget build(BuildContext context) {
    final visible = farms.take(8).toList();
    final maxBoxes = visible.isEmpty
        ? 1
        : visible.map((farm) => farm.totalBoxes).reduce(
              (a, b) => a > b ? a : b,
            );

    return _AnalyticsCard(
      title: 'Detection Volume by Farm',
      subtitle: 'Farm ranking by total bounding box detections',
      icon: Icons.agriculture_outlined,
      child: visible.isEmpty
          ? const _EmptyState(message: 'No farm detection data available.')
          : Column(
              children: visible.map((farm) {
                final progress = maxBoxes == 0
                    ? 0.0
                    : (farm.totalBoxes / maxBoxes).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farm.farmName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Text(
                            '${farm.totalBoxes} boxes',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _ProgressBar(
                        progress: progress,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _LowConfidenceReviewCard extends StatelessWidget {
  final List<Map<String, dynamic>> scans;

  const _LowConfidenceReviewCard({required this.scans});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Low Confidence Review',
      subtitle: 'Scan results that may need human verification',
      icon: Icons.warning_amber_rounded,
      child: scans.isEmpty
          ? const _EmptyState(message: 'No low confidence scans found.')
          : Column(
              children: scans.map((scan) {
                final confidence = _confidenceValue(scan);
                final images = _scanImages(scan);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.priority_high_rounded,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _farmName(scan),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_farmerName(scan)} • ${images.length} image(s)',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _percent(confidence),
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _ScanImageReviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> scans;

  const _ScanImageReviewTable({required this.scans});

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, dynamic>>[];

    for (final scan in scans) {
      final images = _scanImages(scan);

      for (final image in images) {
        rows.add({
          'scan': scan,
          'image': image,
          'boxes': _parseBoxes(image['boxes']),
        });
      }
    }

    rows.sort((a, b) {
      final aDate = _safeText(a['scan']['scandate']);
      final bDate = _safeText(b['scan']['scandate']);
      return bDate.compareTo(aDate);
    });

    return _AnalyticsCard(
      title: 'AI Image Review Table',
      subtitle: 'Image-level detection records with bounding box counts',
      icon: Icons.table_chart_outlined,
      child: rows.isEmpty
          ? const _EmptyState(message: 'No scan image records found.')
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Farm',
                          style: _tableHeaderStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Farmer',
                          style: _tableHeaderStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Pod',
                          style: _tableHeaderStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Boxes',
                          style: _tableHeaderStyle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Confidence',
                          style: _tableHeaderStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...rows.take(12).map((row) {
                  final scan = row['scan'] as Map<String, dynamic>;
                  final image = row['image'] as Map<String, dynamic>;
                  final boxes = row['boxes'] as List<DetectionBox>;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _farmName(scan),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _farmerName(scan),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _safeText(image['podindex']),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            boxes.length.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _percent(_confidenceValue(scan)),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _confidenceColor(
                                _confidenceValue(scan),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4338CA),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final String label;
  final String helper;
  final int value;
  final int total;
  final Color color;

  const _DistributionRow({
    required this.label,
    required this.helper,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Text(
              '$value scans',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              helper,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProgressBar(progress: progress, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              _percent(progress),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: safeProgress,
        minHeight: 9,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _CompactStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompactStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(
  fontSize: 12,
  color: Color(0xFF6B7280),
  fontWeight: FontWeight.w900,
);

List<Map<String, dynamic>> _scanImages(Map<String, dynamic> scan) {
  final raw = scan['scan_images'];

  if (raw is List) {
    return raw.whereType<Map>().map((e) {
      return Map<String, dynamic>.from(e);
    }).toList();
  }

  return [];
}

List<DetectionBox> _parseBoxes(dynamic rawBoxes) {
  if (rawBoxes == null) return [];

  dynamic value = rawBoxes;

  if (rawBoxes is String) {
    try {
      value = jsonDecode(rawBoxes);
    } catch (_) {
      return [];
    }
  }

  if (value is! List) return [];

  final boxes = <DetectionBox>[];

  for (final item in value) {
    if (item is Map) {
      final x1 = _doubleValue(item['x1']);
      final y1 = _doubleValue(item['y1']);
      final x2 = _doubleValue(item['x2']);
      final y2 = _doubleValue(item['y2']);

      boxes.add(
        DetectionBox(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
        ),
      );
    }
  }

  return boxes;
}

int _boxesCount(dynamic rawBoxes) {
  return _parseBoxes(rawBoxes).length;
}

double _confidenceValue(Map<String, dynamic> scan) {
  final raw = scan['confidencescore'];
  final value = _doubleValue(raw);

  if (value > 1) {
    return value / 100;
  }

  return value;
}

String _confidenceLabel(double value) {
  if (value >= 0.80) return 'High';
  if (value >= 0.50) return 'Medium';
  return 'Low';
}

Color _confidenceColor(double value) {
  if (value >= 0.80) return const Color(0xFF16A34A);
  if (value >= 0.50) return const Color(0xFFD97706);
  return const Color(0xFFDC2626);
}

String _farmName(Map<String, dynamic> scan) {
  return scan['farm']?['farmname']?.toString() ?? '-';
}

String _farmerName(Map<String, dynamic> scan) {
  final farmer = scan['farmer'];

  if (farmer == null) return '-';

  final first = farmer['firstname']?.toString() ?? '';
  final last = farmer['lastname']?.toString() ?? '';
  final name = '$first $last'.trim();

  return name.isEmpty ? '-' : name;
}

String _safeText(dynamic value) {
  if (value == null) return '-';

  final text = value.toString().trim();

  return text.isEmpty ? '-' : text;
}

int _intValue(dynamic value) {
  if (value == null) return 0;

  if (value is int) return value;

  return int.tryParse(value.toString()) ?? 0;
}

double _doubleValue(dynamic value) {
  if (value == null) return 0;

  if (value is num) return value.toDouble();

  return double.tryParse(value.toString()) ?? 0;
}

String _percent(double value) {
  final safeValue = value.clamp(0.0, 1.0);
  return '${(safeValue * 100).toStringAsFixed(1)}%';
}