import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/scan_session_helper.dart';
import '../services/scan_session_service.dart';

import '../widgets/scan_session_page_header.dart';
import '../widgets/scan_session_search_section.dart';
import '../widgets/scan_session_table_section.dart';
import '../widgets/scan_session_details_dialog.dart';

class ScanSessionPage extends StatefulWidget {
  const ScanSessionPage({super.key});

  @override
  State<ScanSessionPage> createState() => _ScanSessionPageState();
}

class _ScanSessionPageState extends State<ScanSessionPage> {
  final service = ScanSessionService(Supabase.instance.client);

  final searchController = TextEditingController();

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];

  bool isLoading = true;
  String selectedDecision = 'All';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    setState(() => isLoading = true);

    try {
      final result = await service.fetchScanSessions();

      data = result;
      _applyFilters();
    } catch (e) {
      debugPrint('Failed to fetch scan sessions: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scan sessions: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  List<String> get decisions {
    final values = <String>{
      'All',
      ...data.map((item) => safeText(item['finaldecision'])),
    }.toList();

    values.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      return a.compareTo(b);
    });

    return values;
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();

    final result = data.where((item) {
      final farmer = getFarmerName(item).toLowerCase();
      final farm = getFarmName(item).toLowerCase();
      final decision = safeText(item['finaldecision']);
      final state = safeText(item['farm']?['state']).toLowerCase();
      final district = safeText(item['farm']?['district']).toLowerCase();

      final matchesSearch = farmer.contains(query) ||
          farm.contains(query) ||
          decision.toLowerCase().contains(query) ||
          state.contains(query) ||
          district.contains(query);

      final matchesDecision =
          selectedDecision == 'All' || decision == selectedDecision;

      return matchesSearch && matchesDecision;
    }).toList();

    filtered = result;
  }

  void handleSearch(String value) {
    setState(_applyFilters);
  }

  void handleDecisionChanged(String? value) {
    if (value == null) return;

    setState(() {
      selectedDecision = value;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final decisionValues = decisions;
    if (!decisionValues.contains(selectedDecision)) {
      selectedDecision = 'All';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ScanSessionPageHeader(),
          const SizedBox(height: 16),
          ScanSessionSearchSection(
            controller: searchController,
            selectedDecision: selectedDecision,
            decisions: decisionValues,
            onSearch: handleSearch,
            onDecisionChanged: handleDecisionChanged,
            onRefresh: fetch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ScanSessionTableSection(
              isLoading: isLoading,
              items: filtered,
              onView: (session) => showScanSessionDetailsDialog(
                context: context,
                session: session,
                service: service,
              ),
            ),
          ),
        ],
      ),
    );
  }
}