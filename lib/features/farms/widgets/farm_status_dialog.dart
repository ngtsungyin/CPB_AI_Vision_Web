import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';

Future<bool?> showFarmStatusDialog({
  required BuildContext context,
  required Farm farm,
  required bool newStatus,
}) async {
  final controller = TextEditingController();

  bool canConfirm = false;
  bool isSubmitting = false;

  final keyword = newStatus ? 'ACTIVATE' : 'DEACTIVATE';

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !isSubmitting,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 30,
                  color: Color(0x16000000),
                  offset: Offset(0, 12),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: newStatus
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          newStatus
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                          color: newStatus
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newStatus
                                  ? 'Activate Farm'
                                  : 'Deactivate Farm',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'You are about to ${newStatus ? 'activate' : 'deactivate'} "${farm.farmName}".',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // WARNING
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: newStatus
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: newStatus
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Text(
                      newStatus
                          ? 'This farm will become active and visible for operations.'
                          : 'This farm will be disabled and cannot be used in operations.',
                      style: TextStyle(
                        color: newStatus
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // TYPE CONFIRMATION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        canConfirm = value.trim() == keyword;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Type $keyword to confirm',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),

                // ACTIONS
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: canConfirm
                            ? () {
                                setState(() => isSubmitting = true);
                                Navigator.pop(context, true);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newStatus
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                        child: Text(
                          newStatus ? 'Activate' : 'Deactivate',
                        ),
                      ),
                    ],
                  ),
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