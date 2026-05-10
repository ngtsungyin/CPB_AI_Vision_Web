import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/pesticide_cost_service.dart';
import '../helpers/pesticide_cost_helper.dart';

import '../widgets/pesticide_cost_page_header.dart';
import '../widgets/pesticide_cost_search_section.dart';
import '../widgets/pesticide_cost_table_section.dart';
import '../widgets/pesticide_cost_details_dialog.dart';
import '../widgets/pesticide_cost_edit_dialog.dart';
import '../widgets/pesticide_cost_delete_dialog.dart';

class PesticideCostPage extends StatefulWidget {
  const PesticideCostPage({super.key});

  @override
  State<PesticideCostPage> createState() => _PesticideCostPageState();
}

class _PesticideCostPageState extends State<PesticideCostPage> {
  final service = PesticideCostService(Supabase.instance.client);

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

    final result = await service.fetchPesticideCosts();

    data = result;
    filtered = result;

    setState(() => isLoading = false);
  }

  void search(String query) {
    final q = query.toLowerCase();

    setState(() {
      filtered = data.where((item) {
        return getFarmerName(item).toLowerCase().contains(q) ||
            getFarmName(item).toLowerCase().contains(q) ||
            safeText(item['pesticidebrand']).toLowerCase().contains(q);
      }).toList();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.all(24),
  color: Colors.white,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        const PesticideCostPageHeader(),
        const SizedBox(height: 24),

        PesticideCostSearchSection(
          controller: searchController,
          onRefresh: fetch,
        ),

        const SizedBox(height: 24),

        Expanded(
          child: PesticideCostTableSection(
            isLoading: isLoading,
            items: filtered,
            onView: (item) =>
                showPesticideCostDetailsDialog(context: context, item: item),
            onEdit: (item) => showPesticideCostEditDialog(
              context: context,
              item: item,
              onSave: (updated) async {
                await service.updatePesticideCost(
                  costId: updated['costid'],
                  pesticideBrand: updated['pesticidebrand'],
                  pesticidePrice: updated['pesticideprice'],
                  numSprayPump: updated['numspraypump'],
                  pesticideRate: updated['pesticiderate'],
                  pesticideCost: updated['pesticidecost'],
                );
                fetch();
              },
            ),
            onDelete: (item) async {
              final confirm = await showDeletePesticideCostDialog(
                context: context,
                item: item,
              );

              if (confirm == true) {
                await service.deletePesticideCost(item['costid']);
                fetch();
              }
            },
          ),
        ),
      ],
  )
    );
  }
}
