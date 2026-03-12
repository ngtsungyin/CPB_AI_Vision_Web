// lib/pages/admin_panel.dart
import 'package:flutter/material.dart';
import '../widgets/admin_header.dart';
import '../widgets/sidebar.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';
import 'farm_management_page.dart';
import 'yield_management_page.dart';
import 'geo_view_page.dart';
import 'admin_login.dart'; // Add this import for logout navigation

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Pages for regular navigation (indices 0-4)
  final List<Widget> _pages = [
    const DashboardPage(),
    const UserManagementPage(),
    const FarmManagementPage(),
    const YieldManagementPage(),
    // GeoViewPage is handled separately at index 7
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'User Management',
    'Farm Management',
    'Yield Management',
    'Geo View', // For index 7
  ];

// Alternative color scheme - Blue/White theme
Future<void> _handleLogout() async {
  final bool? confirmLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF2563EB), size: 28), // Bright blue
            SizedBox(width: 8),
            Text(
              'Confirm Logout',
              style: TextStyle(
                color: Color(0xFF1E293B), // Slate dark
                fontWeight: FontWeight.w600,
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
                fontSize: 16,
                color: Color(0xFF475569), // Slate
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Light blue background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)), // Light blue border
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2563EB), // Blue
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to login again to access the admin panel',
                      style: TextStyle(
                        color: Color(0xFF1E40AF), // Dark blue
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
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B), // Slate gray
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Red for logout
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
      );
    },
  );

  if (confirmLogout == true) {
    _performLogout();
  }
}

  // Actual logout logic
  void _performLogout() {
    // Clear any authentication data here
    // For example: AuthManager().logout();
    
    // Navigate back to login page and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AdminLoginPage()),
      (route) => false, // This removes all previous routes
    );
  }

  // Handle sidebar item selection
  void _onItemSelected(int index) {
    // Special case: Logout (index 6)
    if (index == 6) {
      _handleLogout();
      return;
    }
    
    // Regular navigation
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            currentIndex: _currentIndex,
            onItemSelected: _onItemSelected, // Use the new handler
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                AdminHeader(
                  title: _getPageTitle(_currentIndex),
                  scaffoldKey: _scaffoldKey,
                ),

                // Page Content
                Expanded(child: _getPage(_currentIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int index) {
    if (index == 7) {
      return 'Geo View';
    }
    if (index >= 0 && index < _pageTitles.length - 1) {
      return _pageTitles[index];
    }
    return 'Admin Panel'; // Fallback
  }

  Widget _getPage(int index) {
    if (index == 7) {
      return const GeoViewPage();
    }
    if (index >= 0 && index < _pages.length) {
      return _pages[index];
    }
    // Fallback for any unexpected index
    return const Center(
      child: Text('Page not found'),
    );
  }
}