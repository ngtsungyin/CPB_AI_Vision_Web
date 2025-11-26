import 'email_service.dart';

class OtpService {
  static final Map<String, String> _otpStorage = {};
  static final Map<String, DateTime> _otpExpiry = {};

  Future<String> generateOtp(String email) async {
    final otp = _generate6DigitOtp();
    final expiryTime = DateTime.now().add(const Duration(minutes: 10));

    _otpStorage[email] = otp;
    _otpExpiry[email] = expiryTime;

    // Call email service - wait for it to complete
    final emailSent = await EmailService.sendOtpEmail(email, otp);

    if (!emailSent) {
      throw Exception('Failed to process OTP request');
    }

    print('✅ OTP generated and processed for $email: $otp');
    return otp;
  }

  bool verifyOtp(String email, String otp) {
    final storedOtp = _otpStorage[email];
    final expiryTime = _otpExpiry[email];

    if (storedOtp == null || expiryTime == null) {
      return false;
    }

    if (DateTime.now().isAfter(expiryTime)) {
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return false;
    }

    if (storedOtp == otp) {
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return true;
    }

    return false;
  }

  String _generate6DigitOtp() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }
}