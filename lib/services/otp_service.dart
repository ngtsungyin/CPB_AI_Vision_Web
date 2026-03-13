import 'email_service.dart';

class OtpService {
  static final Map<String, String> _otpStorage = {};
  static final Map<String, DateTime> _otpExpiry = {};

  Future<String> generateOtp(String email) async {
    try {
      final otp = _generate6DigitOtp();
      final expiryTime = DateTime.now().add(const Duration(minutes: 10));

      _otpStorage[email] = otp;
      _otpExpiry[email] = expiryTime;

      print('📝 OTP generated for $email: $otp');

      // Try to send email (will work in test mode)
      await EmailService.sendOtpEmail(email, otp);

      return otp;

    } catch (e) {
      print('❌ Error: $e');
      // Emergency fallback
      final otp = _generate6DigitOtp();
      _otpStorage[email] = otp;
      _otpExpiry[email] = DateTime.now().add(const Duration(minutes: 10));
      print('🔑 EMERGENCY OTP: $otp');
      return otp;
    }
  }

  bool verifyOtp(String email, String otp) {
    final storedOtp = _otpStorage[email];
    final expiryTime = _otpExpiry[email];

    if (storedOtp == null || expiryTime == null) {
      print('❌ No OTP found');
      return false;
    }

    if (DateTime.now().isAfter(expiryTime)) {
      print('❌ OTP expired');
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return false;
    }

    if (storedOtp == otp) {
      print('✅ OTP verified');
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return true;
    }

    print('❌ Invalid OTP');
    return false;
  }

  String _generate6DigitOtp() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0').substring(0, 6);
  }
}