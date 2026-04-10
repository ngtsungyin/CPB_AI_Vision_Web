import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/yields/helpers/yield_management_helper.dart';

Future<void> showYieldRecordDetailsDialog({
  required BuildContext context,
  required YieldRecord record,
  required AppUser? farmer,
  required Farm? farm,
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
            _YieldDialogHero(
              record: record,
              farmer: farmer,
              farm: farm,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Record Information',
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Farmer',
                            farmer != null
                                ? '${farmer.firstName} ${farmer.lastName}'
                                : 'N/A',
                          ),
                          _buildDetailRow('Farm', farm?.farmName ?? 'N/A'),
                          _buildDetailRow(
                            'Harvest Date',
                            formatYieldDate(record.harvestDate),
                          ),
                          _buildDetailRow('Bean Type', record.beanType),
                          _buildDetailRow('Bean Grade', record.beanGrade),
                          _buildDetailRow(
                            'Quantity',
                            '${record.quantityKg.toStringAsFixed(1)} kg',
                          ),
                          _buildDetailRow(
                            'Revenue',
                            record.salesRevenue != null
                                ? 'RM ${record.salesRevenue!.toStringAsFixed(2)}'
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Recorded',
                            formatYieldDate(record.createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Remarks',
                      trailing: _Badge(
                        label: (record.remarks != null &&
                                record.remarks!.trim().isNotEmpty)
                            ? 'Available'
                            : 'No remarks',
                        backgroundColor: (record.remarks != null &&
                                record.remarks!.trim().isNotEmpty)
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF3F4F6),
                        textColor: (record.remarks != null &&
                                record.remarks!.trim().isNotEmpty)
                            ? const Color(0xFF047857)
                            : const Color(0xFF6B7280),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          (record.remarks != null &&
                                  record.remarks!.trim().isNotEmpty)
                              ? record.remarks!
                              : 'No remarks were provided for this yield record.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
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

class _YieldDialogHero extends StatelessWidget {
  final YieldRecord record;
  final AppUser? farmer;
  final Farm? farm;

  const _YieldDialogHero({
    required this.record,
    required this.farmer,
    required this.farm,
  });

  @override
  Widget build(BuildContext context) {
    final heroLetter =
        record.beanType.isNotEmpty ? record.beanType[0].toUpperCase() : 'Y';

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
                heroLetter,
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
                    record.beanType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    farm != null
                        ? 'Recorded for ${farm!.farmName}'
                        : 'Farm not available',
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
                        label: record.beanGrade,
                        backgroundColor: const Color(0xFFF3F4F6),
                        textColor: const Color(0xFF374151),
                      ),
                      _Badge(
                        label: '${record.quantityKg.toStringAsFixed(1)} kg',
                        backgroundColor: const Color(0xFFEEF2FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                      _Badge(
                        label: record.salesRevenue != null
                            ? 'RM ${record.salesRevenue!.toStringAsFixed(2)}'
                            : 'No revenue',
                        backgroundColor: const Color(0xFFECFDF5),
                        textColor: const Color(0xFF047857),
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