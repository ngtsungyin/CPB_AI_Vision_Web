import 'package:flutter/material.dart';
import 'package:cpbaivision_app/core/services/database_service.dart';
import 'package:cpbaivision_app/features/dashboard/widgets/stats_overview_card.dart';
import 'package:cpbaivision_app/features/dashboard/widgets/state_distribution_card.dart';
import 'package:cpbaivision_app/features/dashboard/widgets/decision_distribution_card.dart';
import 'package:cpbaivision_app/features/dashboard/widgets/analytics_chart_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DashboardHero(),
            const SizedBox(height: 24),

            RepaintBoundary(
              child: StatsOverviewCard(
                databaseService: DatabaseService(),
              ),
            ),

            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                if (width < 1100) {
                  return const Column(
                    children: [
                      SizedBox(
                        height: 420,
                        child: StateDistributionCard(),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 380,
                        child: DecisionDistributionCard(),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 340,
                        child: AnalyticsChartCard(),
                      ),
                    ],
                  );
                }

                return const Column(
                  children: [
                    SizedBox(
                      height: 420,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: StateDistributionCard(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DecisionDistributionCard(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 340,
                      child: AnalyticsChartCard(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 700;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor users, farm activity, scan volume, and operational insights in one place.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Live Admin View',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor users, farm activity, scan volume, and operational insights in one place.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Live Admin View',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}