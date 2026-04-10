import 'package:flutter/material.dart';
import 'package:cpbaivision_app/shared/models/database_models.dart';

Future<bool?> showFarmStatusDialog({
  required BuildContext context,
  required Farm farm,
  required bool newStatus,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FarmStatusDialog(
      farm: farm,
      newStatus: newStatus,
    ),
  );
}

class _FarmStatusDialog extends StatefulWidget {
  final Farm farm;
  final bool newStatus;

  const _FarmStatusDialog({
    required this.farm,
    required this.newStatus,
  });

  @override
  State<_FarmStatusDialog> createState() => _FarmStatusDialogState();
}

class _FarmStatusDialogState extends State<_FarmStatusDialog> {
  late final TextEditingController _controller;
  late final String _keyword;

  bool _canConfirm = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _keyword = widget.newStatus ? 'ACTIVATE' : 'DEACTIVATE';

    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final matches = _controller.text.trim() == _keyword;
    if (matches != _canConfirm && mounted) {
      setState(() {
        _canConfirm = matches;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(false);
  }

  Future<void> _handleConfirm() async {
    if (!_canConfirm || _isSubmitting) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    // Let the current frame settle before closing the dialog
    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final farm = widget.farm;
    final newStatus = widget.newStatus;

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
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
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                            newStatus ? 'Activate Farm' : 'Deactivate Farm',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You are about to ${newStatus ? 'activate' : 'deactivate'} "${farm.farmName}".',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _controller,
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Type $_keyword to confirm',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onSubmitted: (_) {
                    if (_canConfirm && !_isSubmitting) {
                      _handleConfirm();
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : _handleCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (_canConfirm && !_isSubmitting)
                          ? _handleConfirm
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newStatus
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(newStatus ? 'Activate' : 'Deactivate'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}