import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isDashboardExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                Text(
                  'CPBVision',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDashboardDropdown(),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'User Management',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.agriculture_outlined,
                  label: 'Farm Management',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  label: 'Yield Management',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.work_outline,
                  label: 'Labour Cost',
                  index: 5,
                ),
                _buildNavItem(
                  icon: Icons.science_outlined,
                  label: 'Pesticide Cost',
                  index: 6,
                ),
                _buildNavItem(
                  icon: Icons.insert_chart_outlined,
                  label: 'Scans Report',
                  index: 7,
                ),
                _buildNavItem(
                  icon: Icons.timeline_outlined,
                  label: 'Scan Session',
                  index: 8,
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 9,
                ),
                _buildNavItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  index: 10,
                ),
                _buildNavItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  index: 11,
                ),
                _buildNavItem(
                  icon: Icons.fact_check_outlined,
                  label: 'Admin Audit Log',
                  index: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardDropdown() {
    final isDashboardSelected = widget.currentIndex == 0;
    final isGeoViewSelected = widget.currentIndex == 1;
    final isParentSelected = isDashboardSelected || isGeoViewSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isParentSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isParentSelected
            ? Border.all(color: Colors.blue.withOpacity(0.3))
            : null,
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.dashboard_outlined,
          color: isParentSelected ? Colors.blue : Colors.grey[700],
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
            color: isParentSelected ? Colors.blue : Colors.grey[700],
          ),
        ),
        trailing: Icon(
          _isDashboardExpanded ? Icons.expand_less : Icons.expand_more,
          color: isParentSelected ? Colors.blue : Colors.grey[700],
          size: 20,
        ),
        initiallyExpanded: _isDashboardExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isDashboardExpanded = expanded;
          });
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        children: [
          _buildSubNavItem(
            label: 'Overview',
            index: 0,
            isParentSelected: isParentSelected,
          ),
          _buildSubNavItem(
            label: 'Geo View',
            index: 1,
            isParentSelected: isParentSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildSubNavItem({
    required String label,
    required int index,
    required bool isParentSelected,
  }) {
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Colors.blue
                : (isParentSelected ? Colors.blue[300] : Colors.grey[500]),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.blue[800]
                : (isParentSelected ? Colors.blue[600] : Colors.grey[600]),
          ),
        ),
        onTap: () => widget.onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Colors.blue.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey[700],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey[700],
          ),
        ),
        onTap: () => widget.onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}