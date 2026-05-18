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

  static const Color _bgTop = Color(0xFF111827);
  static const Color _bgBottom = Color(0xFF0F172A);
  static const Color _accent = Color(0xFF22C55E);
  static const Color _accentDark = Color(0xFF15803D);
  static const Color _textPrimary = Color(0xFFE2E8F0);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC57E22).withOpacity(0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      '../assets/images/cocoaguard_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CocoaGuard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Admin Dashboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                  icon: Icons.timeline_outlined,
                  label: 'Scan Session',
                  index: 7,
                ),
                _buildNavItem(
                  icon: Icons.insert_chart_outlined,
                  label: 'Scans Report',
                  index: 8,
                ),
                _buildNavItem(
                  icon: Icons.insights_outlined,
                  label: 'AI Analytics',
                  index: 9,
                ),
                _buildNavItem(
                  icon: Icons.fact_check_outlined,
                  label: 'Admin Audit Log',
                  index: 10,
                ),
                const SizedBox(height: 24),
                _buildSectionLabel('System'),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 11,
                ),
                _buildNavItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  index: 12,
                ),
                _buildNavItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  index: 13,
                  isDanger: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
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
        color: isParentSelected
            ? const Color(0xFF1E293B)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isParentSelected
              ? _accent.withOpacity(0.20)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.white.withOpacity(0.04),
          highlightColor: Colors.white.withOpacity(0.03),
        ),
        child: ExpansionTile(
          leading: Icon(
            Icons.dashboard_outlined,
            color: isParentSelected ? _accent : const Color(0xFFCBD5E1),
          ),
          title: Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: isParentSelected ? FontWeight.w800 : FontWeight.w600,
              color: isParentSelected ? Colors.white : _textPrimary,
            ),
          ),
          trailing: Icon(
            _isDashboardExpanded ? Icons.expand_less : Icons.expand_more,
            color: isParentSelected ? _accent : _textSecondary,
            size: 20,
          ),
          initiallyExpanded: _isDashboardExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isDashboardExpanded = expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide.none,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
      margin: const EdgeInsets.only(left: 18, right: 10, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? _accent.withOpacity(0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? _accent
                : (isParentSelected
                      ? _accent.withOpacity(0.55)
                      : _textSecondary),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.white : _textSecondary,
          ),
        ),
        onTap: () => widget.onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isDanger = false,
  }) {
    final isSelected = widget.currentIndex == index;

    final inactiveIconColor = isDanger
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFCBD5E1);
    final inactiveTextColor = isDanger ? const Color(0xFFFECACA) : _textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(colors: [_accent, _accentDark])
            : null,
        color: isSelected ? null : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : Colors.white.withOpacity(0.04),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _accent.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ListTile(
        minLeadingWidth: 24,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : inactiveIconColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : inactiveTextColor,
          ),
        ),
        onTap: () => widget.onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
