import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/core/services/auth_manager.dart';
import 'package:cpbaivision_app/features/auth/services/auth_gate.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String password;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  final AuthManager _authManager = AuthManager();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _resendCooldown = 0;
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();

    setState(() {
      _resendCooldown = seconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _getOtp().length == 6 &&
        _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtp();
    if (otp.length != 6 || _isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: otp,
      );

      if (response.user != null && mounted) {
        await _authManager.initializeFromSession();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showError(e.message.isNotEmpty
          ? e.message
          : 'Invalid OTP. Please try again.');
      _clearOtpFields();
    } catch (e) {
      _showError('Invalid OTP. Please try again.');
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) {
      _showError('Please wait ${_resendCooldown}s before requesting again.');
      return;
    }

    setState(() => _isResending = true);

    try {
      await _supabase.auth.signInWithOtp(email: widget.email);

      if (mounted) {
        _showSuccess('OTP sent. Please check your email.');
        _clearOtpFields();
        _startCooldown(60);
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('rate') ||
          errorStr.contains('over_email_send_rate_limit')) {
        if (mounted) {
          _showSuccess('OTP sent. Please check your email.');
          _clearOtpFields();
          _startCooldown(60);
        }
      } else {
        if (mounted) {
          _showError('Failed to resend OTP. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _setOtpFromString(String value, {int startIndex = 0}) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return;

    int cursor = startIndex;

    for (int i = 0; i < digitsOnly.length && cursor < 6; i++, cursor++) {
      _otpControllers[cursor].text = digitsOnly[i];
    }

    if (cursor >= 6) {
      _focusNodes[5].requestFocus();
    } else {
      _focusNodes[cursor].requestFocus();
    }

    if (_isOtpComplete()) {
      _verifyOtp();
    }

    setState(() {});
  }

  Future<void> _pasteOtpFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';

    if (text.isEmpty) {
      _showError('Clipboard is empty.');
      return;
    }

    _clearOtpFields();
    _setOtpFromString(text, startIndex: 0);
  }

  void _handleOtpChanged(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      _otpControllers[index].clear();
      return;
    }

    if (digitsOnly.length > 1) {
      _setOtpFromString(digitsOnly, startIndex: index);
      return;
    }

    _otpControllers[index].text = digitsOnly;
    _otpControllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _otpControllers[index].text.length),
    );

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }

    if (_isOtpComplete()) {
      _verifyOtp();
    }

    setState(() {});
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final currentText = _otpControllers[index].text;

      if (currentText.isNotEmpty) {
        _otpControllers[index].clear();
        setState(() {});
        return KeyEventResult.handled;
      }

      if (index > 0) {
        _otpControllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildOtpBox(int index, bool isCompact) {
    return Focus(
      onKeyEvent: (_, event) => _handleKeyEvent(index, event),
      child: SizedBox(
        width: isCompact ? 46 : 54,
        height: isCompact ? 58 : 64,
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction:
              index == 5 ? TextInputAction.done : TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.blue.shade700,
                width: 1.8,
              ),
            ),
          ),
          onChanged: (value) => _handleOtpChanged(index, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: EdgeInsets.all(isCompact ? 24 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF111827), Color(0xFF374151)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: isCompact ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit verification code sent to your admin email to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          size: 18,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    6,
                    (index) => _buildOtpBox(index, isCompact),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _pasteOtpFromClipboard,
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  label: const Text('Paste code'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    icon: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _isVerifying ? 'Verifying...' : 'Complete Sign In',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed:
                          (_isResending || _resendCooldown > 0) ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? 'Resend (${_resendCooldown}s)'
                                  : 'Resend',
                              style: TextStyle(
                                color: _resendCooldown > 0
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade700,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}