import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/yields/helpers/yield_management_helper.dart';

class YieldStatisticsSection extends StatelessWidget {
  final List<YieldRecord> records;

  const YieldStatisticsSection({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final totalYield = calculateTotalYield(records);
    final totalRevenue = calculateTotalRevenue(records);
    final averageYield = calculateAverageYield(records);

    final stats = [
      _YieldStatItem(
        title: 'Total Yield',
        value: '${totalYield.toStringAsFixed(1)} kg',
        icon: Icons.scale,
      ),
      _YieldStatItem(
        title: 'Total Revenue',
        value: 'RM ${totalRevenue.toStringAsFixed(2)}',
        icon: Icons.attach_money,
      ),
      _YieldStatItem(
        title: 'Avg Yield',
        value: '${averageYield.toStringAsFixed(1)} kg',
        icon: Icons.trending_up,
      ),
      _YieldStatItem(
        title: 'Records',
        value: records.length.toString(),
        icon: Icons.list_alt,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1100) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  Expanded(child: _YieldStatCard(item: stats[i])),
                  if (i != stats.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
          );
        }

        if (width >= 650) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _YieldStatCard(item: stats[0])),
                    const SizedBox(width: 16),
                    Expanded(child: _YieldStatCard(item: stats[1])),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _YieldStatCard(item: stats[2])),
                    const SizedBox(width: 16),
                    Expanded(child: _YieldStatCard(item: stats[3])),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                _YieldStatCard(item: stats[i]),
                if (i != stats.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _YieldStatItem {
  final String title;
  final String value;
  final IconData icon;

  const _YieldStatItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _YieldStatCard extends StatelessWidget {
  final _YieldStatItem item;

  const _YieldStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(item.icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}