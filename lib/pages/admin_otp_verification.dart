// lib/pages/admin_otp_verification.dart
import 'package:flutter/material.dart';
import '../services/otp_service.dart';
import '../services/auth_manager.dart';
import 'admin_panel.dart';

class AdminOtpVerificationPage extends StatefulWidget {
  final String email;
  final OtpService otpService;

  const AdminOtpVerificationPage({
    super.key,
    required this.email,
    required this.otpService,
  });

  @override
  State<AdminOtpVerificationPage> createState() => _AdminOtpVerificationPageState();
}

class _AdminOtpVerificationPageState extends State<AdminOtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _authManager = AuthManager();

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _setupOtpFields();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _setupOtpFields() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < _otpControllers.length - 1) {
          _focusNodes[i + 1].requestFocus();
        }

        if (_isOtpComplete() && i == _otpControllers.length - 1) {
          _verifyOtp();
        }
      });
    }
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete()) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final otpCode = _getOtpCode();
      final isValid = widget.otpService.verifyOtp(widget.email, otpCode);

      if (isValid) {
        // Mark user as logged in
        _authManager.login(widget.email);

        // Success - navigate to admin panel
        _navigateToAdminPanel();
      } else {
        throw Exception('Invalid or expired OTP');
      }

    } catch (e) {
      _showErrorDialog('Invalid OTP code. Please try again.');
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final newOtp = await widget.otpService.generateOtp(widget.email);
      _showNewOtpForTesting(newOtp);
      _clearOtpFields();

    } catch (e) {
      _showErrorDialog('Failed to resend OTP: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showNewOtpForTesting(String otp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New OTP Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New OTP for testing:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                otp,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToAdminPanel() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AdminPanel()),
          (route) => false,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: const Text('Verify OTP'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Enter OTP Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'We sent a 6-digit verification code to:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              _buildOtpInputSection(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  child: _isVerifying
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Verify & Access Admin Panel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Resend Code'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit code (check console for testing OTP)',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}