// pages/dashboard/stats_overview_card.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/responsive_utils.dart';

class StatsOverviewCard extends StatelessWidget {
  final DatabaseService databaseService;

  const StatsOverviewCard({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: databaseService.getDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorStats();
        }

        final stats = snapshot.data ?? {};

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('Total Users', '${stats['totalUsers'] ?? 0}', Icons.people, Colors.blue),
            _buildStatCard('Active Farms', '${stats['activeFarms'] ?? 0}', Icons.agriculture, Colors.green),
            _buildStatCard('Total Scans', '${stats['totalScans'] ?? 0}', Icons.camera_alt, Colors.orange),
            _buildStatCard('Pending Users', '${stats['pendingUsers'] ?? 0}', Icons.pending_actions, Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildErrorStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Users', '0', Icons.people, Colors.blue),
        _buildStatCard('Active Farms', '0', Icons.agriculture, Colors.green),
        _buildStatCard('Total Scans', '0', Icons.camera_alt, Colors.orange),
        _buildStatCard('Pending Users', '0', Icons.pending_actions, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}