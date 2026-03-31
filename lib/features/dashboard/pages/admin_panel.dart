import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/features/auth/services/session_notice.dart';
import 'package:cpbaivision_app/core/widgets/admin_header.dart';
import 'package:cpbaivision_app/core/widgets/sidebar.dart';
import 'dashboard_page.dart';
import 'package:cpbaivision_app/features/users/pages/user_management_page.dart';
import 'package:cpbaivision_app/features/farms/pages/farm_management_page.dart';
import 'package:cpbaivision_app/features/yields/pages/yield_management_page.dart';
import 'package:cpbaivision_app/features/geo/pages/geo_view_page.dart';
import 'package:cpbaivision_app/features/admin/pages/admin_audit_page.dart';


class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggingOut = false;

  final List<Widget> _pages = const [
    DashboardPage(),
    UserManagementPage(),
    FarmManagementPage(),
    YieldManagementPage(),

  ];

  final List<String> _pageTitles = const [
    'Dashboard',
    'User Management',
    'Farm Management',
    'Yield Management',
    'Geo View',
    'Admin Audit Log',
  ];

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFF2563EB),
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You will need to login again to access the admin panel.',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      SessionNotice.show('You have been logged out successfully.');
      await Supabase.instance.client.auth.signOut();
      // No manual navigation here.
      // AuthGate will automatically route user to login page.
    } catch (e) {
      SessionNotice.show('Unable to log out cleanly. Please sign in again.');
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        // ignore second failure
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _onItemSelected(int index) {
    if (_isLoggingOut) return;

    if (index == 6) {
      _handleLogout();
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  String _getPageTitle(int index) {
    if (index == 7) {
      return 'Geo View';
    }
    if (index >= 0 && index < _pageTitles.length - 1) {
      return _pageTitles[index];
    }
    if (index == 8) {
      return 'Admin Audit Log';
    }
    return 'Admin Panel';
  }

  Widget _getPage(int index) {
    if (index == 7) {
      return const GeoViewPage();
    }
    if (index == 8) {
      return const AdminAuditPage();
    }
    if (index >= 0 && index < _pages.length) {
      return _pages[index];
    }
    return const Center(
      child: Text('Page not found'),
    );
  }

  Widget _buildSidebar() {
    return Sidebar(
      currentIndex: _currentIndex,
      onItemSelected: _onItemSelected,
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Column(
          children: [
            AdminHeader(
              title: _getPageTitle(_currentIndex),
              scaffoldKey: _scaffoldKey,
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF7F8FA),
                child: RepaintBoundary(
                  child: _getPage(_currentIndex),
                ),
              ),
            ),
          ],
        ),
        if (_isLoggingOut)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.12),
              child: const Center(
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.6),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Signing out...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;
        final isTablet = width >= 768 && width < 1100;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF7F8FA),
          drawer: isDesktop
              ? null
              : Drawer(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: SafeArea(
                    child: _buildSidebar(),
                  ),
                ),
          body: SafeArea(
            child: isDesktop
                ? Row(
                    children: [
                      SizedBox(
                        width: 280,
                        child: RepaintBoundary(
                          child: _buildSidebar(),
                        ),
                      ),
                      Expanded(
                        child: _buildMainContent(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: _buildMainContent(),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: isDesktop
              ? null
              : isTablet
                  ? null
                  : FloatingActionButton.small(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      onPressed: _isLoggingOut
                          ? null
                          : () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                      child: const Icon(Icons.menu_rounded),
                    ),
        );
      },
    );
  }
}