import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:cpbaivision_app/features/auth/services/session_notice.dart';
import 'package:cpbaivision_app/core/widgets/admin_header.dart';
import 'package:cpbaivision_app/core/widgets/sidebar.dart';

import 'dashboard_page.dart';
import 'package:cpbaivision_app/features/users/pages/user_management_page.dart';
import 'package:cpbaivision_app/features/farms/pages/farm_management_page.dart';
import 'package:cpbaivision_app/features/yields/pages/yield_management_page.dart';
import 'package:cpbaivision_app/features/geo/pages/geo_view_page.dart';
import 'package:cpbaivision_app/features/admin/pages/admin_audit_page.dart';

import 'package:cpbaivision_app/features/labour_costs/pages/labour_cost_page.dart';
import 'package:cpbaivision_app/features/pesticide_costs/pages/pesticide_cost_page.dart';
import 'package:cpbaivision_app/features/scan_sessions/pages/scan_session_page.dart';
import 'package:cpbaivision_app/features/scan_reports/pages/scans_report_page.dart';
import 'package:cpbaivision_app/features/ai_analytics/pages/ai_analytics_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _TourFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TourFeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSupportPage extends StatelessWidget {
  final VoidCallback onStartAdminTour;
  final VoidCallback onStartScanSessionTour;
  final VoidCallback onStartScanReportTour;
  final VoidCallback onStartAiAnalyticsTour;
  final VoidCallback onStartAuditLogTour;

  const _HelpSupportPage({
    required this.onStartAdminTour,
    required this.onStartScanSessionTour,
    required this.onStartScanReportTour,
    required this.onStartAiAnalyticsTour,
    required this.onStartAuditLogTour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpHero(onStartAdminTour: onStartAdminTour),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 980;

                final cards = [
                  _TourGuideCard(
                    icon: Icons.dashboard_outlined,
                    title: 'Global Admin Tour',
                    description:
                        'Learn the basic layout, sidebar navigation, and dashboard overview.',
                    buttonLabel: 'Replay Admin Tour',
                    color: const Color(0xFF2563EB),
                    onPressed: onStartAdminTour,
                  ),
                  _TourGuideCard(
                    icon: Icons.image_search_outlined,
                    title: 'Scan Session Tour',
                    description:
                        'Learn how to review scan images, sample groups, GPS maps, and AI bounding boxes.',
                    buttonLabel: 'Start Scan Tour',
                    color: const Color(0xFF16A34A),
                    onPressed: onStartScanSessionTour,
                  ),
                  _TourGuideCard(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'Scans Report Tour',
                    description:
                        'Learn how to view reports and export individual or selected records.',
                    buttonLabel: 'Start Report Tour',
                    color: const Color(0xFFDC2626),
                    onPressed: onStartScanReportTour,
                  ),
                  _TourGuideCard(
                    icon: Icons.insights_outlined,
                    title: 'AI Analytics Tour',
                    description:
                        'Learn how to interpret confidence levels, bounding box analytics, and low-confidence scans.',
                    buttonLabel: 'Start AI Tour',
                    color: const Color(0xFF9333EA),
                    onPressed: onStartAiAnalyticsTour,
                  ),
                  _TourGuideCard(
                    icon: Icons.fact_check_outlined,
                    title: 'Audit Log Tour',
                    description:
                        'Learn how admin activity tracking supports accountability and transparency.',
                    buttonLabel: 'Start Audit Tour',
                    color: const Color(0xFFD97706),
                    onPressed: onStartAuditLogTour,
                  ),
                ];

                if (isCompact) {
                  return Column(
                    children: cards
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: card,
                          ),
                        )
                        .toList(),
                  );
                }

                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: (constraints.maxWidth - 36) / 3,
                          child: card,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 28),
            const _QuickGuideSection(),
          ],
        ),
      ),
    );
  }
}

class _HelpHero extends StatelessWidget {
  final VoidCallback onStartAdminTour;

  const _HelpHero({required this.onStartAdminTour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Guided Tours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Replay onboarding tours and learn how to use CocoaGuard admin modules effectively.',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onStartAdminTour,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Replay Main Tour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          );

          final graphic = Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: Color(0xFF22C55E),
              size: 58,
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [graphic, const SizedBox(height: 20), content],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 24),
              graphic,
            ],
          );
        },
      ),
    );
  }
}

class _TourGuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final Color color;
  final VoidCallback onPressed;

  const _TourGuideCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF6B7280),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: Text(buttonLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withOpacity(0.35)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickGuideSection extends StatelessWidget {
  const _QuickGuideSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Admin Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          _GuideItem(
            number: '01',
            title: 'Review scan evidence',
            description:
                'Open Scan Sessions to inspect uploaded images, GPS location, and AI bounding boxes.',
          ),
          _GuideItem(
            number: '02',
            title: 'Export reports carefully',
            description:
                'Use Scans Report to export one report at a time or selected reports with each report separated into its own PDF page.',
          ),
          _GuideItem(
            number: '03',
            title: 'Check AI reliability',
            description:
                'Use AI Analytics to review confidence levels, detection counts, and low-confidence scans.',
          ),
          _GuideItem(
            number: '04',
            title: 'Track admin actions',
            description:
                'Use Admin Audit Log to review important administrative activities.',
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _GuideItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggingOut = false;
  final GlobalKey _sidebarTourKey = GlobalKey();
  final GlobalKey _dashboardTourKey = GlobalKey();
  final GlobalKey _geoTourKey = GlobalKey();
  final GlobalKey _scanSessionTourKey = GlobalKey();
  final GlobalKey _scanReportTourKey = GlobalKey();
  final GlobalKey _aiAnalyticsTourKey = GlobalKey();
  final GlobalKey _auditTourKey = GlobalKey();
  final GlobalKey _helpTourKey = GlobalKey();

  BuildContext? _showcaseContext;

  bool _hasCheckedTour = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTour();
    });
  }

  void _checkFirstTimeTour() {
    if (_hasCheckedTour) return;
    _hasCheckedTour = true;

    final hasSeenTour =
        html.window.localStorage['cocoaguard_admin_tour_seen'] == 'true';

    if (!hasSeenTour && mounted) {
      _showTourWelcomeDialog();
    }
  }

  Future<void> _showTourWelcomeDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 34,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF111827), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.tour_outlined,
                          color: Color(0xFF22C55E),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to CocoaGuard Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'A quick guided walkthrough for first-time admins.',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Would you like a quick guided tour?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The tour will show you how to navigate the admin dashboard. You can also replay specific tours later from Help & Support.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _TourFeatureChip(
                            icon: Icons.dashboard_outlined,
                            label: 'Dashboard',
                          ),
                          _TourFeatureChip(
                            icon: Icons.image_search_outlined,
                            label: 'Scan Sessions',
                          ),
                          _TourFeatureChip(
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'Report Export',
                          ),
                          _TourFeatureChip(
                            icon: Icons.insights_outlined,
                            label: 'AI Analytics',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                        ),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        icon: const Icon(Icons.play_arrow_rounded, size: 19),
                        label: const Text('Start Tour'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    html.window.localStorage['cocoaguard_admin_tour_seen'] = 'true';

    if (result == true && mounted) {
      _startAdminTour();
    }
  }

  void _startShowcaseForPage({
    required int pageIndex,
    required List<GlobalKey> keys,
  }) {
    setState(() {
      _currentIndex = pageIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 180), () {
        final showcaseContext = _showcaseContext;

        if (showcaseContext == null || !mounted) {
          debugPrint('Showcase context is not ready.');
          return;
        }

        ShowCaseWidget.of(showcaseContext).startShowCase(keys);
      });
    });
  }

  void _startAdminTour() {
    _startShowcaseForPage(
      pageIndex: 0,
      keys: [_sidebarTourKey, _dashboardTourKey],
    );
  }

  void _startScanSessionTour() {
    _startShowcaseForPage(
      pageIndex: 7,
      keys: [_sidebarTourKey, _scanSessionTourKey],
    );
  }

  void _startScanReportTour() {
    _startShowcaseForPage(
      pageIndex: 8,
      keys: [_sidebarTourKey, _scanReportTourKey],
    );
  }

  void _startAiAnalyticsTour() {
    _startShowcaseForPage(
      pageIndex: 9,
      keys: [_sidebarTourKey, _aiAnalyticsTourKey],
    );
  }

  void _startAuditLogTour() {
    _startShowcaseForPage(
      pageIndex: 10,
      keys: [_sidebarTourKey, _auditTourKey],
    );
  }

  void _startHelpTour() {
    _startShowcaseForPage(pageIndex: 12, keys: [_helpTourKey]);
  }

  void replayAdminTour() {
    _startAdminTour();
  }

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
              Icon(Icons.logout_rounded, color: Color(0xFF2563EB), size: 26),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
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
    } catch (e) {
      SessionNotice.show('Unable to log out cleanly. Please sign in again.');
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
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

    if (index == 13) {
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
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Geo View';
      case 2:
        return 'User Management';
      case 3:
        return 'Farm Management';
      case 4:
        return 'Yield Management';
      case 5:
        return 'Labour Cost';
      case 6:
        return 'Pesticide Cost';
      case 7:
        return 'Scan Session';
      case 8:
        return 'Scans Report';
      case 9:
        return 'AI Analytics';
      case 10:
        return 'Admin Audit Log';
      case 11:
        return 'Settings';
      case 12:
        return 'Help & Support';
      default:
        return 'Admin Panel';
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Showcase(
          key: _dashboardTourKey,
          title: 'Dashboard Overview',
          description:
              'This page gives a quick summary of system activity, farm data, scans, and key monitoring indicators. For detailed module walkthroughs, open Help & Support and choose a page-specific tour.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const DashboardPage(),
        );

      case 1:
        return Showcase(
          key: _geoTourKey,
          title: 'Geo View',
          description:
              'Use Geo View to understand farm distribution and location-based monitoring insights.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const GeoViewPage(),
        );

      case 2:
        return const UserManagementPage();

      case 3:
        return const FarmManagementPage();

      case 4:
        return const YieldManagementPage();

      case 5:
        return const LabourCostPage();

      case 6:
        return const PesticideCostPage();

      case 7:
        return Showcase(
          key: _scanSessionTourKey,
          title: 'Scan Sessions',
          description:
              'This page lets admins inspect scan evidence: grouped sample images, GPS map location, and AI bounding boxes with toggle preview.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const ScanSessionPage(),
        );

      case 8:
        return Showcase(
          key: _scanReportTourKey,
          title: 'Scans Report',
          description:
              'Use this page to view scan reports, export one report individually, or select multiple reports and export them with each report separated into its own PDF page.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const ScansReportPage(),
        );

      case 9:
        return Showcase(
          key: _aiAnalyticsTourKey,
          title: 'AI Analytics',
          description:
              'This page summarizes model confidence, bounding box counts, low-confidence scans, and farm-level detection patterns.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const AiAnalyticsPage(),
        );

      case 10:
        return Showcase(
          key: _auditTourKey,
          title: 'Admin Audit Log',
          description:
              'This page records important admin actions, helping improve accountability and traceability.',
          targetBorderRadius: BorderRadius.circular(18),
          child: const AdminAuditPage(),
        );

      case 11:
        return const Center(child: Text('Settings page coming soon'));

      case 12:
        return Showcase(
          key: _helpTourKey,
          title: 'Help & Support',
          description:
              'Replay guided tours and learn how each admin module works from this page.',
          targetBorderRadius: BorderRadius.circular(18),
          child: _HelpSupportPage(
            onStartAdminTour: _startAdminTour,
            onStartScanSessionTour: _startScanSessionTour,
            onStartScanReportTour: _startScanReportTour,
            onStartAiAnalyticsTour: _startAiAnalyticsTour,
            onStartAuditLogTour: _startAuditLogTour,
          ),
        );

      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildSidebar() {
    return Showcase(
      key: _sidebarTourKey,
      title: 'Sidebar Navigation',
      description:
          'Use the sidebar to move between dashboard modules such as farms, scan sessions, reports, AI analytics, and system settings.',
      targetBorderRadius: BorderRadius.circular(18),
      child: Sidebar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
      ),
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
              onNotificationPressed: () {
                // Navigate to User Management page (index 1)
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF7F8FA),
                child: RepaintBoundary(child: _getPage(_currentIndex)),
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
    return ShowCaseWidget(
      builder: (showcaseContext) {
        _showcaseContext = showcaseContext;

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
                      child: SafeArea(child: _buildSidebar()),
                    ),

              body: SafeArea(
                child: isDesktop
                    ? Row(
                        children: [
                          SizedBox(width: 280, child: _buildSidebar()),
                          Expanded(child: _buildMainContent()),
                        ],
                      )
                    : Column(children: [Expanded(child: _buildMainContent())]),
              ),

              floatingActionButton: isDesktop || isTablet
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
      },
    );
  }
}
