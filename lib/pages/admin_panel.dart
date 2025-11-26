import 'package:flutter/material.dart';
import '../widgets/admin_header.dart';
import '../widgets/sidebar.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';
import 'farm_management_page.dart';
import 'yield_management_page.dart';
import 'geo_view_page.dart'; // Add this import

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const DashboardPage(),
    const UserManagementPage(),
    const FarmManagementPage(),
    const YieldManagementPage(),
    const GeoViewPage(), // Add Geo View page at index 7
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'User Management',
    'Farm Management',
    'Yield Management',
    'Geo View', // Add title for Geo View
  ];

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
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
    return _pageTitles[index];
  }

  Widget _getPage(int index) {
    if (index == 7) {
      return const GeoViewPage();
    }
    return _pages[index];
  }
}