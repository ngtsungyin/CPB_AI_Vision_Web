import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_manager.dart';
import 'admin_panel.dart';

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
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final AuthManager _authManager = AuthManager();
  final _supabase = Supabase.instance.client;

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // No cooldown on page load
    _resendCooldown = 0;
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
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
      if (mounted && _resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _resendCooldown = 0;
          });
        }
      }
    });
  }

  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtp();
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: otp,
      );

      if (response.user != null && mounted) {
        _authManager.login(widget.email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanel()),
        );
      }
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
      _showError('Please wait ${_resendCooldown} seconds');
      return;
    }

    setState(() => _isResending = true);

    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
      );

      if (mounted) {
        _showSuccess('OTP resent! Check your email');
        _clearOtpFields();
        _startCooldown(60);
      }

    } catch (e) {
      print('Resend error: $e');

      // Check if it's a rate limit error (email still gets sent)
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('rate') || errorStr.contains('over_email_send_rate_limit')) {
        // Email was actually sent, just treat as success
        if (mounted) {
          _showSuccess('OTP sent! Check your email');
          _clearOtpFields();
          _startCooldown(60);
        }
      } else {
        if (mounted) {
          _showError('Failed to resend. Please try again.');
        }
      }

    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.security, size: 64, color: Colors.blue[700]),
                const SizedBox(height: 24),
                Text(
                  'Enter OTP Code',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a 6-digit code to:',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: isMobile ? 45 : 50,
                      height: isMobile ? 55 : 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (_getOtp().length == 6) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text('Verify', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive code?", style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: (_isResending || _resendCooldown > 0) ? null : _resendOtp,
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
                          color: _resendCooldown > 0 ? Colors.grey[400] : Colors.blue[700],
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