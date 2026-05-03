import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/labour_cost_service.dart';
import '../helpers/labour_cost_helper.dart';

import '../widgets/labour_cost_page_header.dart';
import '../widgets/labour_cost_search_section.dart';
import '../widgets/labour_cost_table_section.dart';
import '../widgets/labour_cost_details_dialog.dart';
import '../widgets/labour_cost_edit_dialog.dart';
import '../widgets/labour_cost_delete_dialog.dart';

class LabourCostPage extends StatefulWidget {
  const LabourCostPage({super.key});

  @override
  State<LabourCostPage> createState() => _LabourCostPageState();
}

class _LabourCostPageState extends State<LabourCostPage> {
  final service = LabourCostService(Supabase.instance.client);

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    setState(() => isLoading = true);

    final result = await service.fetchLabourCosts();

    data = result;
    filtered = result;

    setState(() => isLoading = false);
  }

  void search(String query) {
    final q = query.toLowerCase();

    setState(() {
      filtered = data.where((item) {
        return getFarmerName(item).toLowerCase().contains(q) ||
            getFarmName(item).toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LabourCostPageHeader(),
        const SizedBox(height: 16),

        LabourCostSearchSection(
          controller: searchController,
          onRefresh: fetch,
        ),

        const SizedBox(height: 16),

        Expanded(
          child: LabourCostTableSection(
            isLoading: isLoading,
            items: filtered,
            onView: (item) =>
                showLabourCostDetailsDialog(context: context, item: item),
            onEdit: (item) => showLabourCostEditDialog(
              context: context,
              item: item,
              onSave: (updated) async {
                await service.updateLabourCost(
                  labourId: updated['labourid'],
                  dailyLabourCost: updated['dailylabourcost'],
                  farmAreaSprayPerDay: 0,
                  workCostPerDay: updated['workcostperday'],
                  wetCocoaBeanPricePerKg: 0,
                  pesticideFrequencyPerYear: 0,
                  expectedYieldPerHectare:
                      updated['expectedyieldperhectare'],
                );
                fetch();
              },
            ),
            onDelete: (item) async {
              final confirm = await showDeleteLabourCostDialog(
                context: context,
                item: item,
              );

              if (confirm == true) {
                await service.deleteLabourCost(item['labourid']);
                fetch();
              }
            },
          ),
        ),
      ],
    );
  }
}