import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/farms/helpers/farm_management_helper.dart';

Future<void> showFarmDetailsDialog({
  required BuildContext context,
  required Farm farm,
  required AppUser? owner,
  required List<Scan> scans,
}) async {
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
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
            _FarmDialogHero(
              farm: farm,
              owner: owner,
              scansCount: scans.length,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Farm Information',
                      child: Column(
                        children: [
                          _buildDetailRow('Farm Name', farm.farmName),
                          _buildDetailRow(
                            'Owner',
                            owner != null
                                ? '${owner.firstName} ${owner.lastName}'
                                : 'N/A',
                          ),
                          _buildDetailRow('Email', owner?.email ?? 'N/A'),
                          _buildDetailRow(
                            'Location',
                            '${farm.village}, ${farm.district}',
                          ),
                          _buildDetailRow('State', farm.state),
                          _buildDetailRow('Postcode', farm.postcode),
                          _buildDetailRow(
                            'Area',
                            '${farm.areaHectares.toStringAsFixed(2)} hectares',
                          ),
                          _buildDetailRow(
                            'Tree Count',
                            '${farm.treeCount} trees',
                          ),
                          _buildDetailRow(
                            'Status',
                            farm.isActive ? 'Active' : 'Inactive',
                          ),
                          _buildDetailRow(
                            'Created',
                            formatFarmDate(farm.createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Scan Statistics',
                      trailing: _Badge(
                        label: '${scans.length} scans',
                        backgroundColor: const Color(0xFFEEF2FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                      child: scans.isEmpty
                          ? Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No scan records available for this farm.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildDetailRow('Total Scans', '${scans.length}'),
                                _buildDetailRow(
                                  'Last Scan',
                                  formatFarmDate(scans.last.scanDate),
                                ),
                                _buildDetailRow(
                                  'Avg Eggs / Scan',
                                  calculateAverageEggs(scans)
                                      .toStringAsFixed(1),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
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
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
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

class _FarmDialogHero extends StatelessWidget {
  final Farm farm;
  final AppUser? owner;
  final int scansCount;

  const _FarmDialogHero({
    required this.farm,
    required this.owner,
    required this.scansCount,
  });

  @override
  Widget build(BuildContext context) {
    final initials = farm.farmName.isNotEmpty
        ? farm.farmName.trim()[0].toUpperCase()
        : 'F';

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
                    farm.farmName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    owner != null
                        ? 'Owned by ${owner!.firstName} ${owner!.lastName}'
                        : 'Owner not available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: farm.isActive ? 'Active' : 'Inactive',
                        backgroundColor: farm.isActive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        textColor: farm.isActive
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                      ),
                      _Badge(
                        label: '${farm.treeCount} trees',
                        backgroundColor: const Color(0xFFF3F4F6),
                        textColor: const Color(0xFF374151),
                      ),
                      _Badge(
                        label: '${scansCount} scans',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

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

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
          child: Text(
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