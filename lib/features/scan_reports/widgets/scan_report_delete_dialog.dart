import 'package:flutter/material.dart';
import '../helpers/scan_report_helper.dart';

Future<bool?> showDeleteScanReportDialog({
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
            constraints: const BoxConstraints(maxWidth: 540),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Scan Report',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'You are deleting the scan report for ${getFarmName(item)}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
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
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: canDelete
                          ? () => Navigator.of(dialogContext).pop(true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
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