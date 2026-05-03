import 'package:flutter/material.dart';

Future<void> showLabourCostEditDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
  required Future<void> Function(Map<String, dynamic> updated) onSave,
}) async {
  final dailyController =
      TextEditingController(text: item['dailylabourcost'].toString());
  final workController =
      TextEditingController(text: item['workcostperday'].toString());
  final yieldController =
      TextEditingController(text: item['expectedyieldperhectare'].toString());

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
                  'Edit Labour Cost',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: dailyController,
                  decoration:
                      const InputDecoration(labelText: 'Daily Labour Cost'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: workController,
                  decoration:
                      const InputDecoration(labelText: 'Work Cost Per Day'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: yieldController,
                  decoration: const InputDecoration(
                      labelText: 'Expected Yield / Hectare'),
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
                                'labourid': item['labourid'],
                                'dailylabourcost':
                                    double.tryParse(dailyController.text) ?? 0,
                                'workcostperday':
                                    double.tryParse(workController.text) ?? 0,
                                'expectedyieldperhectare':
                                    double.tryParse(yieldController.text) ?? 0,
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