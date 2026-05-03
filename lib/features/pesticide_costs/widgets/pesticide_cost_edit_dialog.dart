import 'package:flutter/material.dart';

Future<void> showPesticideCostEditDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
  required Future<void> Function(Map<String, dynamic> updated) onSave,
}) async {
  final brandController =
      TextEditingController(text: item['pesticidebrand'] ?? '');
  final priceController =
      TextEditingController(text: item['pesticideprice'].toString());
  final pumpController =
      TextEditingController(text: item['numspraypump'].toString());
  final rateController =
      TextEditingController(text: item['pesticiderate'].toString());
  final costController =
      TextEditingController(text: item['pesticidecost'].toString());

  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Pesticide Cost',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: brandController,
                  decoration:
                      const InputDecoration(labelText: 'Pesticide Brand'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: 'Pesticide Price'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: pumpController,
                  decoration:
                      const InputDecoration(labelText: 'Number of Spray Pumps'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: rateController,
                  decoration:
                      const InputDecoration(labelText: 'Pesticide Rate'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: costController,
                  decoration:
                      const InputDecoration(labelText: 'Total Cost'),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setState(() => isSaving = true);

                              final updated = {
                                'costid': item['costid'],
                                'pesticidebrand': brandController.text,
                                'pesticideprice':
                                    double.tryParse(priceController.text) ?? 0,
                                'numspraypump':
                                    int.tryParse(pumpController.text) ?? 0,
                                'pesticiderate':
                                    double.tryParse(rateController.text) ?? 0,
                                'pesticidecost':
                                    double.tryParse(costController.text) ?? 0,
                              };

                              Navigator.pop(context);
                              await onSave(updated);
                            },
                      child: const Text('Save'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    ),
  );
}