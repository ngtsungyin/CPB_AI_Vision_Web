// lib/services/otp_service.dart
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
      print('📧 Calling EmailService.sendOtpEmail...');

      // Call email service
      final emailSent = await EmailService.sendOtpEmail(email, otp);

      if (!emailSent) {
        print('⚠️ Email sending reported failure, but OTP is still available');
        // Don't throw exception, just warn - OTP is still in console for testing
        print('==========================================');
        print('🔑 FALLBACK - OTP FOR $email: $otp');
        print('==========================================');
      } else {
        print('✅ Email service completed successfully');
      }

      return otp;

    } catch (e) {
      print('❌ Error in generateOtp: $e');
      
      // Still generate OTP even if email fails (for testing)
      final otp = _generate6DigitOtp();
      final expiryTime = DateTime.now().add(const Duration(minutes: 10));
      
      _otpStorage[email] = otp;
      _otpExpiry[email] = expiryTime;
      
      print('==========================================');
      print('🔑 EMERGENCY OTP FOR $email: $otp');
      print('==========================================');
      
      return otp; // Return OTP anyway so testing can continue
    }
  }

  bool verifyOtp(String email, String otp) {
    final storedOtp = _otpStorage[email];
    final expiryTime = _otpExpiry[email];

    if (storedOtp == null || expiryTime == null) {
      print('❌ No OTP found for $email');
      return false;
    }

    if (DateTime.now().isAfter(expiryTime)) {
      print('❌ OTP expired for $email');
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return false;
    }

    if (storedOtp == otp) {
      print('✅ OTP verified successfully for $email');
      _otpStorage.remove(email);
      _otpExpiry.remove(email);
      return true;
    }

    print('❌ Invalid OTP for $email');
    return false;
  }

  String _generate6DigitOtp() {
    // More reliable OTP generation
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0').substring(0, 6);
  }
  
  // Helper method to get current OTP (for testing)
  String? getCurrentOtp(String email) {
    return _otpStorage[email];
  }
}