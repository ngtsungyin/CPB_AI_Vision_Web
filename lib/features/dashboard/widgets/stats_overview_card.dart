import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';

class StatsOverviewCard extends StatefulWidget {
  final DatabaseService databaseService;

  const StatsOverviewCard({
    super.key,
    required this.databaseService,
  });

  @override
  State<StatsOverviewCard> createState() => _StatsOverviewCardState();
}

class _StatsOverviewCardState extends State<StatsOverviewCard> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = widget.databaseService.getDashboardStats();
  }

  @override
  void didUpdateWidget(covariant StatsOverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.databaseService != widget.databaseService) {
      _statsFuture = widget.databaseService.getDashboardStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = snapshot.data ?? {};

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int columns;
            double aspectRatio;

            if (width < 500) {
              columns = 1;
              aspectRatio = 2.2;
            } else if (width < 900) {
              columns = 2;
              aspectRatio = 1.7;
            } else if (width < 1200) {
              columns = 3;
              aspectRatio = 1.5;
            } else {
              columns = 4;
              aspectRatio = 1.35;
            }

            final items = [
              _StatItem(
                'Total Users',
                '${stats['totalUsers'] ?? 0}',
                Icons.people_rounded,
              ),
              _StatItem(
                'Active Farms',
                '${stats['activeFarms'] ?? 0}',
                Icons.agriculture_rounded,
              ),
              _StatItem(
                'Total Scans',
                '${stats['totalScans'] ?? 0}',
                Icons.camera_alt_rounded,
              ),
              _StatItem(
                'Pending Users',
                '${stats['pendingUsers'] ?? 0}',
                Icons.pending_actions_rounded,
              ),
            ];

            return RepaintBoundary(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  return _SaaSStatCard(
                    item: items[index],
                    isNarrow: width < 500,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem(this.title, this.value, this.icon);
}

class _SaaSStatCard extends StatelessWidget {
  final _StatItem item;
  final bool isNarrow;

  const _SaaSStatCard({
    required this.item,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 16 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isNarrow ? 18 : 20,
              backgroundColor: Colors.grey.shade100,
              child: Icon(
                item.icon,
                size: isNarrow ? 18 : 20,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isNarrow ? 12 : 16),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isNarrow ? 22 : 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isNarrow ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}