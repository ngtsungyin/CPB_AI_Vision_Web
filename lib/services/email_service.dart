import 'package:emailjs/emailjs.dart';

class EmailService {
  // EmailJS configuration - Sign up at https://www.emailjs.com
  static const String _serviceId = 'your_service_id';    // Get from EmailJS
  static const String _templateId = 'your_template_id';  // Get from EmailJS
  static const String _publicKey = 'your_public_key';    // Get from EmailJS
  
  // For development/testing
  static bool _testMode = true; // Keep true until EmailJS is set up
  
  // Send OTP email using EmailJS (works on web)
  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    print('📧 Email Service: Preparing to send OTP: $otpCode to: $toEmail');
    
    if (_testMode) {
      print('🔧 TEST MODE - OTP for $toEmail: $otpCode');
      print('==========================================');
      print('🔑 OTP: $otpCode');
      print('==========================================');
      return true;
    }
    
    try {
      // Send email using EmailJS
      await EmailJS.send(
        _serviceId,
        _templateId,
        {
          'to_email': toEmail,
          'to_name': toEmail.split('@')[0],
          'otp_code': otpCode,
          'from_name': 'CPB AI Vision Admin',
        },
        Options(
          publicKey: _publicKey,
        ),
      );
      
      print('✅ Email sent successfully via EmailJS');
      return true;
      
    } catch (e) {
      print('❌ EmailJS error: $e');
      print('==========================================');
      print('⚠️ FALLBACK - OTP for $toEmail: $otpCode');
      print('==========================================');
      return false;
    }
  }
}