import 'package:flutter/material.dart';

Future<bool?> showDeletePesticideCostDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
}) async {
  final controller = TextEditingController();
  bool canDelete = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Pesticide Record',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Type DELETE to confirm deletion.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      canDelete = value.trim() == 'DELETE';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Type DELETE',
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: canDelete
                          ? () =>
                              Navigator.of(dialogContext).pop(true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ),
  );

  controller.dispose();
  return result;
}