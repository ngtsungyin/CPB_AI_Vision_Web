import 'package:flutter/material.dart';
import '../helpers/scan_session_helper.dart';
import '../services/scan_session_service.dart';
import 'dart:convert';

Future<void> showScanSessionDetailsDialog({
  required BuildContext context,
  required Map<String, dynamic> session,
  required ScanSessionService service,
}) async {
  final sessionId =
      session['id']?.toString() ?? session['sessionid']?.toString() ?? '';

  // 2. Your debug print goes exactly here!
  debugPrint('--- DEBUG: Fetching scans for Session ID: $sessionId ---');
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
                            label: '${scans.length} scans',
                            backgroundColor: const Color(0xFFEEF2FF),
                            textColor: const Color(0xFF4338CA),
                          ),
                          child: scans.isEmpty
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
                                  children: scans
                                      .map((scan) => _ScanCard(scan: scan))
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

List<String> extractScanImages(Map<String, dynamic> scan) {
  // Check imagepath first, fallback to imageurl
  final rawData = (scan['imageurl'] ?? scan['imagepath'])?.toString().trim();

  if (rawData == null || rawData.isEmpty) return [];

  // 1. Handle the new JSON array of URLs
  if (rawData.startsWith('[')) {
    try {
      final List<dynamic> parsedList = jsonDecode(rawData);
      return parsedList.map((url) => url.toString()).toList();
    } catch (e) {
      debugPrint('Error parsing image array: $e');
      return [];
    }
  }

  // 2. Handle if it is already a single full URL
  if (rawData.startsWith('http')) {
    return [rawData];
  }

  // 3. Fallback for older relative paths
  const supabaseUrl = 'https://zjunvkimsgbkrwhvknhz.supabase.co';
  const bucket = 'CocoaPodEgg_Image';
  return ['$supabaseUrl/storage/v1/object/public/$bucket/$rawData'];
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

class _ScanCard extends StatelessWidget {
  final Map<String, dynamic> scan;

  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    final imageUrls = extractScanImages(scan);
    // Grab the first URL to use as the cover image
    final displayUrl = imageUrls.isNotEmpty ? imageUrls.first : '';
    final gps = scan['gpslocation'];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: displayUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFF6B7280),
                    ),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      displayUrl,
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
              children: [
                _miniDetail('Eggs', safeText(scan['eggsdetected'])),
                _miniDetail('Confidence', safeText(scan['confidencescore'])),
                _miniDetail('Date', formatScanSessionDate(scan['scandate'])),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showImageModal(context, displayUrl),
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: const Text('Image'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showGpsModal(context, gps),
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

  void _showImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scan Image'),
        content: SizedBox(
          width: 620,
          height: 520,
          child: imageUrl.isEmpty
              ? const Center(child: Text('No image URL available.'))
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Center(child: Text('Unable to load image.'));
                  },
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

  void _showGpsModal(BuildContext context, dynamic gps) {
    final gpsText = formatGps(gps);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
