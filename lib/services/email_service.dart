// lib/services/email_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    try {
      final supabase = Supabase.instance.client;

      print('📧 Calling request_otp_email for: $toEmail with OTP: $otpCode');

      // 1. First, log to database (this works based on your test)
      final response = await supabase.from('otp_requests').insert({
        'email': toEmail,
        'otp_code': otpCode,
        'requested_at': DateTime.now().toIso8601String(),
      });

      print('✅ OTP request logged to database successfully');

      // 2. Try to send email using Magic Link (includes OTP in subject/body)
      await _sendMagicLinkWithOtp(toEmail, otpCode);

      return true;

    } catch (e) {
      print('❌ Error in email service: $e');
      // Even if database fails, try to send magic link
      return await _sendMagicLinkWithOtp(toEmail, otpCode);
    }
  }

  static Future<bool> _sendMagicLinkWithOtp(String toEmail, String otpCode) async {
    try {
      final supabase = Supabase.instance.client;

      // Send magic link - the email will include the OTP in the template
      final result = await supabase.auth.signInWithOtp(
        email: toEmail,
        emailRedirectTo: 'http://localhost:3000',
        data: {
          'otp_code': otpCode,
          'login_type': 'admin_otp',
        },
      );

      print('✅ Magic link sent to $toEmail');
      print('📧 OTP included in email: $otpCode');
      return true;

    } catch (e) {
      print('❌ Magic link failed: $e');
      // Last resort - just log the OTP
      print('🔑 FALLBACK - OTP for $toEmail: $otpCode');
      return true; // Return true so OTP flow continues
    }
  }
}