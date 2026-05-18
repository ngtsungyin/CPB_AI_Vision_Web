import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/scan_session_helper.dart';
import '../services/scan_session_service.dart';

Future<void> showScanSessionDetailsDialog({
  required BuildContext context,
  required Map<String, dynamic> session,
  required ScanSessionService service,
}) async {
  final sessionId = safeText(session['sessionid']);

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Hero(session: session),
            Flexible(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: service.fetchScansBySession(sessionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load scans: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final scans = snapshot.data ?? [];
                  final sampleGroups = buildSampleScanGroups(scans);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        _SectionCard(
                          title: 'Session Summary',
                          child: Column(
                            children: [
                              _detailRow('Farmer', getFarmerName(session)),
                              _detailRow(
                                'Email',
                                safeText(session['farmer']?['email']),
                              ),
                              _detailRow('Farm', getFarmName(session)),
                              _detailRow(
                                'State',
                                safeText(session['farm']?['state']),
                              ),
                              _detailRow(
                                'District',
                                safeText(session['farm']?['district']),
                              ),
                              _detailRow(
                                'Village',
                                safeText(session['farm']?['village']),
                              ),
                              _detailRow(
                                'Total Eggs',
                                safeText(session['totaleggs']),
                              ),
                              _detailRow(
                                'Average Eggs',
                                safeText(session['averageeggs']),
                              ),
                              _detailRow(
                                'Cumulative Eggs',
                                safeText(session['cumulativeeggs']),
                              ),
                              _detailRow(
                                'Final Decision',
                                safeText(session['finaldecision']),
                              ),
                              _detailRow(
                                'Recommendation',
                                safeText(session['recommendationreason']),
                              ),
                              _detailRow(
                                'Session Date',
                                formatScanSessionDate(session['sessiondate']),
                              ),
                              _detailRow(
                                'Farm GPS',
                                '${safeText(session['farm']?['latitude'])}, ${safeText(session['farm']?['longitude'])}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SectionCard(
                          title: 'Related Scan Images & GPS',
                          trailing: _Badge(
                            label: '${sampleGroups.length} sample(s)',
                            backgroundColor: const Color(0xFFEEF2FF),
                            textColor: const Color(0xFF4338CA),
                          ),
                          child: sampleGroups.isEmpty
                              ? const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'No scan images found for this session.',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                )
                              : Wrap(
                                  spacing: 14,
                                  runSpacing: 14,
                                  children: sampleGroups
                                      .map((group) => _ScanCard(group: group))
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

List<String> buildScanImageUrls(Map<String, dynamic> scan) {
  const supabaseUrl = 'https://zjunvkimsgbkrwhvknhz.supabase.co';
  const bucket = 'CocoaPodEgg_Image';

  List<String> extractValues(dynamic raw) {
    if (raw == null) return [];

    final text = raw.toString().trim();

    if (text.isEmpty || text == '[]' || text.toLowerCase() == 'null') {
      return [];
    }

    try {
      final decoded = jsonDecode(text);

      if (decoded is List) {
        return decoded
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      if (decoded is String && decoded.trim().isNotEmpty) {
        return [decoded.trim()];
      }
    } catch (_) {
      return [text];
    }

    return [];
  }

  final urls = extractValues(
    scan['imageurl'],
  ).where((url) => url.startsWith('http')).toList();

  if (urls.isNotEmpty) {
    return urls;
  }

  final paths = extractValues(scan['imagepath']);

  return paths
      .where((path) {
        if (path.isEmpty) return false;

        // Web cannot open local Android cache paths.
        if (path.startsWith('/data/') ||
            path.startsWith('file://') ||
            path.contains('/cache/') ||
            path.contains('image_picker') ||
            path.contains('scaled_')) {
          return false;
        }

        return true;
      })
      .map((path) {
        if (path.startsWith('http')) {
          return path;
        }

        return '$supabaseUrl/storage/v1/object/public/$bucket/$path';
      })
      .toList();
}

class _Hero extends StatelessWidget {
  final Map<String, dynamic> session;

  const _Hero({required this.session});

  @override
  Widget build(BuildContext context) {
    final farmName = getFarmName(session);
    final initials = farmName.isNotEmpty && farmName != '-'
        ? farmName.trim()[0].toUpperCase()
        : 'S';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF111827),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scan session by ${getFarmerName(session)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label:
                            '${safeText(session['cumulativeeggs'])} cumulative eggs',
                        backgroundColor: const Color(0xFFF3F4F6),
                        textColor: const Color(0xFF374151),
                      ),
                      _Badge(
                        label: safeText(session['finaldecision']),
                        backgroundColor: const Color(0xFFEEF2FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanImageItem {
  final String imageUrl;
  final int sampleNumber;
  final int podIndex;
  final int imageIndex;
  final List<List<double>> boxes;

  const ScanImageItem({
    required this.imageUrl,
    required this.sampleNumber,
    required this.podIndex,
    required this.imageIndex,
    required this.boxes,
  });
}

class SampleScanGroup {
  final int sampleNumber;
  final Map<String, dynamic> scan;
  final List<ScanImageItem> imageItems;

  const SampleScanGroup({
    required this.sampleNumber,
    required this.scan,
    required this.imageItems,
  });
}

List<List<double>> parseBoxes(dynamic rawBoxes) {
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

  final parsed = <List<double>>[];

  for (final item in value) {
    if (item is Map) {
      final x1 = double.tryParse(item['x1']?.toString() ?? '');
      final y1 = double.tryParse(item['y1']?.toString() ?? '');
      final x2 = double.tryParse(item['x2']?.toString() ?? '');
      final y2 = double.tryParse(item['y2']?.toString() ?? '');

      if (x1 != null && y1 != null && x2 != null && y2 != null) {
        parsed.add([x1, y1, x2, y2]);
      }
    } else if (item is List && item.length >= 4) {
      final x1 = double.tryParse(item[0].toString());
      final y1 = double.tryParse(item[1].toString());
      final x2 = double.tryParse(item[2].toString());
      final y2 = double.tryParse(item[3].toString());

      if (x1 != null && y1 != null && x2 != null && y2 != null) {
        parsed.add([x1, y1, x2, y2]);
      }
    }
  }

  return parsed;
}

bool _isLocalOnlyImagePath(String path) {
  final value = path.trim();

  if (value.isEmpty) return true;

  // Admin web cannot open local Android cache paths.
  return value.startsWith('/data/') ||
      value.startsWith('file://') ||
      value.contains('/cache/') ||
      value.contains('image_picker') ||
      value.contains('scaled_');
}

String _toPublicScanImageUrl(String rawPathOrUrl) {
  const supabaseUrl = 'https://zjunvkimsgbkrwhvknhz.supabase.co';
  const bucket = 'CocoaPodEgg_Image';

  final value = rawPathOrUrl.trim();

  if (value.startsWith('http')) return value;
  if (_isLocalOnlyImagePath(value)) return '';

  return '$supabaseUrl/storage/v1/object/public/$bucket/$value';
}

List<dynamic> _decodePossibleList(dynamic raw) {
  if (raw == null) return [];

  if (raw is List) return raw;

  final text = raw.toString().trim();

  if (text.isEmpty || text == '[]' || text.toLowerCase() == 'null') {
    return [];
  }

  try {
    final decoded = jsonDecode(text);

    if (decoded is List) return decoded;
    if (decoded is String && decoded.trim().isNotEmpty) return [decoded.trim()];
    if (decoded is Map) return [decoded];
  } catch (_) {
    return [text];
  }

  return [];
}

List<ScanImageItem> buildGroupedScanImages(
  Map<String, dynamic> scan, {
  required int sampleNumber,
}) {
  final rawImages = scan['scan_images'];

  if (rawImages is List && rawImages.isNotEmpty) {
    final items = rawImages
        .whereType<Map>()
        .map((item) {
          final rawUrl = item['imageurl']?.toString().trim() ?? '';
          final rawPath = item['imagepath']?.toString().trim() ?? '';
          final url = rawUrl.startsWith('http')
              ? rawUrl
              : _toPublicScanImageUrl(rawPath);

          if (url.isEmpty || !url.startsWith('http')) return null;

          return ScanImageItem(
            imageUrl: url,
            sampleNumber: sampleNumber,
            podIndex: int.tryParse(item['podindex']?.toString() ?? '') ?? 0,
            imageIndex: int.tryParse(item['imageindex']?.toString() ?? '') ?? 0,
            boxes: parseBoxes(item['boxes']),
          );
        })
        .whereType<ScanImageItem>()
        .toList();

    items.sort((a, b) {
      final podCompare = a.podIndex.compareTo(b.podIndex);
      if (podCompare != 0) return podCompare;
      return a.imageIndex.compareTo(b.imageIndex);
    });

    if (items.isNotEmpty) return items;
  }

  // Fallback for older rows where the scan table itself contains either:
  // 1) imageurl = JSON list of public URLs, or
  // 2) imagepath = JSON list of objects/paths.
  final legacyItems = <ScanImageItem>[];

  final urlValues = _decodePossibleList(scan['imageurl']);
  for (int i = 0; i < urlValues.length; i++) {
    final raw = urlValues[i];
    final url = raw is Map
        ? _toPublicScanImageUrl(
            (raw['imageurl'] ?? raw['imagepath'] ?? raw['path'] ?? '')
                .toString(),
          )
        : _toPublicScanImageUrl(raw.toString());

    if (url.isEmpty || !url.startsWith('http')) continue;

    legacyItems.add(
      ScanImageItem(
        imageUrl: url,
        sampleNumber: sampleNumber,
        podIndex: raw is Map
            ? int.tryParse(raw['podindex']?.toString() ?? '') ?? 0
            : 0,
        imageIndex: raw is Map
            ? int.tryParse(raw['imageindex']?.toString() ?? '') ?? i
            : i,
        boxes: raw is Map ? parseBoxes(raw['boxes']) : [],
      ),
    );
  }

  if (legacyItems.isNotEmpty) return legacyItems;

  final pathValues = _decodePossibleList(scan['imagepath']);
  for (int i = 0; i < pathValues.length; i++) {
    final raw = pathValues[i];
    final path = raw is Map
        ? (raw['imagepath'] ?? raw['path'] ?? raw['imageurl'] ?? '').toString()
        : raw.toString();
    final url = _toPublicScanImageUrl(path);

    if (url.isEmpty || !url.startsWith('http')) continue;

    legacyItems.add(
      ScanImageItem(
        imageUrl: url,
        sampleNumber: sampleNumber,
        podIndex: raw is Map
            ? int.tryParse(raw['podindex']?.toString() ?? '') ?? 0
            : 0,
        imageIndex: raw is Map
            ? int.tryParse(raw['imageindex']?.toString() ?? '') ?? i
            : i,
        boxes: raw is Map ? parseBoxes(raw['boxes']) : [],
      ),
    );
  }

  legacyItems.sort((a, b) {
    final podCompare = a.podIndex.compareTo(b.podIndex);
    if (podCompare != 0) return podCompare;
    return a.imageIndex.compareTo(b.imageIndex);
  });

  return legacyItems;
}

List<SampleScanGroup> buildSampleScanGroups(List<Map<String, dynamic>> scans) {
  final sortedScans = [...scans];

  sortedScans.sort((a, b) {
    DateTime parseDate(Map<String, dynamic> scan) {
      final raw = scan['scandate']?.toString();
      return raw == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return parseDate(a).compareTo(parseDate(b));
  });

  return sortedScans.asMap().entries.map((entry) {
    final sampleNumber = entry.key + 1;
    final scan = entry.value;

    return SampleScanGroup(
      sampleNumber: sampleNumber,
      scan: scan,
      imageItems: buildGroupedScanImages(scan, sampleNumber: sampleNumber),
    );
  }).toList();
}

class _GpsPoint {
  final double latitude;
  final double longitude;

  const _GpsPoint({required this.latitude, required this.longitude});
}

_GpsPoint? parseGpsPoint(dynamic gps) {
  if (gps == null) return null;

  try {
    dynamic value = gps;

    if (gps is String) {
      final text = gps.trim();

      if (text.isEmpty || text.toLowerCase() == 'null') {
        return null;
      }

      try {
        value = jsonDecode(text);
      } catch (_) {
        final parts = text.split(',');

        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());

          if (lat != null && lng != null) {
            return _GpsPoint(latitude: lat, longitude: lng);
          }
        }

        return null;
      }
    }

    if (value is Map) {
      final latRaw =
          value['latitude'] ??
          value['lat'] ??
          value['Latitude'] ??
          value['LAT'];

      final lngRaw =
          value['longitude'] ??
          value['lng'] ??
          value['lon'] ??
          value['Longitude'] ??
          value['LNG'] ??
          value['LON'];

      final lat = double.tryParse(latRaw.toString());
      final lng = double.tryParse(lngRaw.toString());

      if (lat != null && lng != null) {
        return _GpsPoint(latitude: lat, longitude: lng);
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

class AdminBoxPainter extends CustomPainter {
  final List<List<double>> boxes;

  AdminBoxPainter(this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final labelPaint = Paint()
      ..color = const Color(0xCC16A34A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < boxes.length; i++) {
      final box = boxes[i];

      if (box.length < 4) continue;

      final rect = Rect.fromLTRB(
        box[0] * size.width,
        box[1] * size.height,
        box[2] * size.width,
        box[3] * size.height,
      );

      canvas.drawRect(rect, boxPaint);

      final labelRect = Rect.fromLTWH(
        rect.left,
        (rect.top - 18).clamp(0, size.height),
        48,
        18,
      );

      canvas.drawRect(labelRect, labelPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Egg ${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(labelRect.left + 4, labelRect.top + 2));
    }
  }

  @override
  bool shouldRepaint(covariant AdminBoxPainter oldDelegate) {
    return oldDelegate.boxes != boxes;
  }
}

class _ScanCard extends StatelessWidget {
  final SampleScanGroup group;

  const _ScanCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final scan = group.scan;
    final imageItems = group.imageItems;
    final imageUrls = imageItems.map((item) => item.imageUrl).toList();
    final firstImageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

    final groupedByPod = <int, List<ScanImageItem>>{};

    for (final item in imageItems) {
      groupedByPod.putIfAbsent(item.podIndex, () => []).add(item);
    }
    final gps = scan['gpslocation'];

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 185,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: firstImageUrl.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 42,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No scan image',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              firstImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 42,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                );
                              },
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.10),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.38),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.science_outlined,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Sample ${group.sampleNumber} • ${imageUrls.length} image(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.egg_alt_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${safeText(scan['eggsdetected'])} eggs',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (imageItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.collections_outlined,
                          size: 17,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sample ${group.sampleNumber} Images',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...groupedByPod.entries.map((entry) {
                      final podIndex = entry.key;
                      final podImages = entry.value;

                      final title = podIndex <= 0
                          ? 'Ungrouped Images'
                          : 'Pod $podIndex';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${podImages.length} image(s)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            SizedBox(
                              height: 58,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: podImages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final item = podImages[index];
                                  final globalIndex = imageItems.indexOf(item);

                                  return InkWell(
                                    onTap: () => _showImageModal(
                                      context,
                                      imageItems,
                                      initialIndex: globalIndex < 0
                                          ? 0
                                          : globalIndex,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return const Icon(
                                              Icons.broken_image_outlined,
                                              size: 22,
                                              color: Color(0xFF6B7280),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _miniDetail('Sample', 'Sample ${group.sampleNumber}'),
                      _miniDetail(
                        'Confidence',
                        safeText(scan['confidencescore']),
                      ),
                      _miniDetail(
                        'Scan Date',
                        formatScanSessionDate(scan['scandate']),
                      ),
                      _miniDetail('Total Images', imageItems.length.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: imageItems.isEmpty
                            ? null
                            : () => _showImageModal(context, imageItems),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: const Text(
                          'View Images',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showGpsModal(context, gps),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text(
                          'View Map',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
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

  void _showImageModal(
    BuildContext context,
    List<ScanImageItem> imageItems, {
    int initialIndex = 0,
  }) {
    showDialog(
      context: context,
      builder: (_) => _BoundingBoxImageDialog(
        imageItems: imageItems,
        initialIndex: initialIndex,
      ),
    );
  }

  void _showGpsModal(BuildContext context, dynamic gps) {
    final gpsText = formatGps(gps);
    final gpsPoint = parseGpsPoint(gps);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        title: Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Color(0xFF2563EB),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan GPS Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Location captured during scan submission',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: 760,
          height: 560,
          child: gpsPoint == null
              ? Center(
                  child: Container(
                    width: 440,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off_outlined,
                          size: 54,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No valid GPS location available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          gpsText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF2563EB),
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Captured Coordinates',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SelectableText(
                                    '${gpsPoint.latitude}, ${gpsPoint.longitude}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${gpsPoint.latitude},${gpsPoint.longitude}',
                                );

                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(
                                  color: Color(0xFFBFDBFE),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 17,
                              ),
                              label: const Text(
                                'Google Maps',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  gpsPoint.latitude,
                                  gpsPoint.longitude,
                                ),
                                initialZoom: 17,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.cpbaivision_admin',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        gpsPoint.latitude,
                                        gpsPoint.longitude,
                                      ),
                                      width: 58,
                                      height: 58,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x33000000),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: const Color(0xFFFEE2E2),
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.location_pin,
                                          size: 38,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _miniDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
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
}

class _BoundingBoxImageDialog extends StatefulWidget {
  final List<ScanImageItem> imageItems;
  final int initialIndex;

  const _BoundingBoxImageDialog({
    required this.imageItems,
    required this.initialIndex,
  });

  @override
  State<_BoundingBoxImageDialog> createState() =>
      _BoundingBoxImageDialogState();
}

class _BoundingBoxImageDialogState extends State<_BoundingBoxImageDialog> {
  bool showBoxes = true;

  @override
  Widget build(BuildContext context) {
    final imageItems = widget.imageItems;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Scan Images',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Row(
            children: [
              const Text(
                'Bounding boxes',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: showBoxes,
                onChanged: (value) {
                  setState(() => showBoxes = value);
                },
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 820,
        height: 600,
        child: imageItems.isEmpty
            ? const Center(child: Text('No image URL available.'))
            : DefaultTabController(
                length: imageItems.length,
                initialIndex: widget.initialIndex,
                child: Column(
                  children: [
                    if (imageItems.length > 1)
                      TabBar(
                        isScrollable: true,
                        labelColor: const Color(0xFF111827),
                        unselectedLabelColor: const Color(0xFF6B7280),
                        tabs: imageItems.map((item) {
                          final podLabel = item.podIndex <= 0
                              ? 'Sample ${item.sampleNumber} • Image ${item.imageIndex + 1}'
                              : 'Sample ${item.sampleNumber} • Pod ${item.podIndex} • Img ${item.imageIndex + 1}';

                          return Tab(text: podLabel);
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: imageItems.map((item) {
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.center_focus_strong_outlined,
                                      size: 18,
                                      color: Color(0xFF16A34A),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.boxes.length} detected egg box(es)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 5,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) {
                                              return const Center(
                                                child: Text(
                                                  'Unable to load image.',
                                                ),
                                              );
                                            },
                                          ),
                                          if (showBoxes &&
                                              item.boxes.isNotEmpty)
                                            CustomPaint(
                                              painter: AdminBoxPainter(
                                                item.boxes,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}
