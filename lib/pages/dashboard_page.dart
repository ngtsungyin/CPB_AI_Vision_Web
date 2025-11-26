// pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';
import 'dashboard/stats_overview_card.dart';
import 'dashboard/analytics_chart_card.dart';
import 'dashboard/state_distribution_card.dart';
import 'dashboard/decision_distribution_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Overview Cards
          StatsOverviewCard(databaseService: _databaseService),
          const SizedBox(height: 24),

          // Analytics Line Chart
          AnalyticsChartCard(),
          const SizedBox(height: 24),

          // Bottom Section with Bar Chart and Pie Chart
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return ResponsiveUtils.isMobile(context)
        ? _buildMobileLayout()
        : _buildDesktopLayout();
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        StateDistributionCard(),
        const SizedBox(height: 16),
        DecisionDistributionCard(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return SizedBox(
      height: 500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: StateDistributionCard()),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: DecisionDistributionCard()),
        ],
      ),
    );
  }
}