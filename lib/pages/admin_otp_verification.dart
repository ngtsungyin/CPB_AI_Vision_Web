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
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.green),
            SizedBox(width: 8),
            Text('New OTP Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A new verification code has been sent to:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your OTP Code:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    otp,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
            ),
            child: const Text('Continue'),
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
            child: const Text('Try Again'),
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
    // Get screen size for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    
    // Calculate responsive card width
    double cardWidth;
    if (isMobile) {
      cardWidth = screenSize.width * 0.9; // 90% on mobile
    } else if (isTablet) {
      cardWidth = 500; // Fixed width on tablet
    } else {
      cardWidth = 450; // Fixed width on desktop
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[700],
          ),
          onPressed: _goBack,
        ),
        title: Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main verification card
              Container(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  minWidth: isMobile ? screenSize.width * 0.9 : 400,
                ),
                child: _buildVerificationCard(isMobile),
              ),
              // Footer credit (optional)
              if (!isMobile) ...[
                const SizedBox(height: 32),
                Text(
                  'CPB AI Vision • Secure Two-Factor Authentication',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon section with gradient
          Container(
            width: isMobile ? 70 : 80,
            height: isMobile ? 70 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[600]!, Colors.green[400]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: isMobile ? 35 : 40,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Enter OTP Code',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Email info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Instruction text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We sent a 6-digit verification code to your email',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isMobile ? 13 : 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // OTP input fields
          _buildOtpInputSection(isMobile),
          const SizedBox(height: 32),

          // Verify button
          SizedBox(
            width: double.infinity,
            height: isMobile ? 50 : 54,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Text(
                'Verify & Access Admin Panel',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Resend section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code?",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isResending ? null : _resendOtp,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: _isResending
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.green[700]!),
                    ),
                  )
                      : Text(
                    'Resend Code',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputSection(bool isMobile) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: isMobile ? 45 : 50,
              height: isMobile ? 55 : 60,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'Enter the 6-digit code from your email',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isMobile ? 11 : 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}