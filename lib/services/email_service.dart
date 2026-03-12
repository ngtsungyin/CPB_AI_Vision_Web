// lib/services/email_service.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Email configuration - REPLACE WITH YOUR ACTUAL EMAIL
  static const String _smtpEmail = 'ngtsungyin@gmail.com'; // Your Gmail
  static const String _smtpPassword = 'evxqattwiabgeckk'; // Gmail App Password
  
  // For development/testing - set to false when ready to send real emails
  static bool _testMode = true; // Start with true for testing
  
  // Send OTP email
  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    print('📧 Email Service: Preparing to send OTP: $otpCode to: $toEmail');
    
    if (_testMode) {
      print('🔧 TEST MODE - Email would be sent with OTP: $otpCode');
      print('==========================================');
      print('🔑 OTP FOR $toEmail: $otpCode');
      print('==========================================');
      return true; // Return true so OTP flow continues
    }
    
    try {
      // Configure SMTP server (using Gmail as example)
      final smtpServer = gmail(_smtpEmail, _smtpPassword);
      
      // Create the email message
      final message = Message()
        ..from = Address(_smtpEmail, 'CPB AI Vision Admin')
        ..recipients.add(toEmail)
        ..subject = '🔐 Your Admin Login OTP Code'
        ..html = _buildOtpEmailHtml(otpCode)
        ..text = _buildOtpEmailText(otpCode);
      
      // Send the email
      final sendReport = await send(message, smtpServer);
      
      print('✅ Email sent successfully to $toEmail');
      return true;
      
    } catch (e) {
      print('❌ Email sending failed: $e');
      print('==========================================');
      print('⚠️ EMAIL FAILED - OTP FOR $toEmail: $otpCode');
      print('==========================================');
      return false;
    }
  }
  
  // HTML email template
  static String _buildOtpEmailHtml(String otpCode) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; }
        .header h1 { color: white; margin: 0; }
        .content { padding: 40px 30px; }
        .otp-box { background: #f8f9fa; border: 2px dashed #667eea; border-radius: 12px; padding: 20px; text-align: center; margin: 30px 0; }
        .otp-code { font-size: 48px; font-weight: bold; letter-spacing: 8px; color: #667eea; font-family: monospace; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>CPB AI Vision</h1>
          <p style="color: rgba(255,255,255,0.9);">Admin Login Verification</p>
        </div>
        <div class="content">
          <h2>Your One-Time Password (OTP)</h2>
          <p>Please use the following 6-digit code to complete your admin login. This code will expire in <strong>10 minutes</strong>.</p>
          <div class="otp-box">
            <span class="otp-code">$otpCode</span>
          </div>
          <p style="color: #999; font-size: 12px;">If you didn't request this code, please ignore this email.</p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }
  
  static String _buildOtpEmailText(String otpCode) {
    return '''
CPB AI Vision - Admin Login Verification

Your One-Time Password (OTP) is: $otpCode

This code will expire in 10 minutes.

If you didn't request this code, please ignore this email.
    ''';
  }
}