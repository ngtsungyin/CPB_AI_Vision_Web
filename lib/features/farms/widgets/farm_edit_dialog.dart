import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';

Future<void> showFarmEditDialog({
  required BuildContext context,
  required Farm farm,
  required Future<void> Function(Farm updated) onSave,
}) async {
  final nameController = TextEditingController(text: farm.farmName);
  final villageController = TextEditingController(text: farm.village);
  final districtController = TextEditingController(text: farm.district);

  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Farm',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Farm Name'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: villageController,
                  decoration: const InputDecoration(labelText: 'Village'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(labelText: 'District'),
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

                              final updated = farm.copyWith(
                                farmName: nameController.text,
                                village: villageController.text,
                                district: districtController.text,
                              );

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