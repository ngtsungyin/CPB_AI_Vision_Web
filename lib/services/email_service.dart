// lib/services/email_service.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Email configuration - REPLACE WITH YOUR ACTUAL EMAIL
  static const String _smtpEmail = 'your-email@gmail.com'; // Your Gmail
  static const String _smtpPassword = 'your-app-password'; // Gmail App Password
  
  // For development/testing - set to false to actually send emails
  static bool _testMode = false; // Set to false to send real emails
  
  // Send OTP email
  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    print('📧 Preparing to send OTP: $otpCode to: $toEmail');
    
    if (_testMode) {
      print('🔧 TEST MODE - Email would be sent with OTP: $otpCode');
      print('==========================================');
      print('OTP FOR $toEmail: $otpCode');
      print('==========================================');
      return true;
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
        ..text = _buildOtpEmailText(otpCode); // Plain text version
      
      // Send the email
      final sendReport = await send(message, smtpServer);
      
      print('✅ Email sent successfully to $toEmail');
      print('📧 Message ID: ${sendReport.toString()}');
      print('🔑 OTP sent: $otpCode');
      
      return true;
      
    } on MailerException catch (e) {
      print('❌ MailerException: ${e.toString()}');
      
      // Show detailed errors
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      
      // Fallback to console
      print('==========================================');
      print('⚠️ EMAIL FAILED - OTP FOR $toEmail: $otpCode');
      print('==========================================');
      return false;
      
    } catch (e) {
      print('❌ Unexpected error: $e');
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
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
      <div style="max-width: 600px; margin: 20px auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        
        <!-- Header with gradient -->
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 28px;">CPB AI Vision</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0;">Admin Login Verification</p>
        </div>
        
        <!-- Content -->
        <div style="padding: 40px 30px;">
          <h2 style="color: #333; margin-top: 0;">Your One-Time Password (OTP)</h2>
          
          <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
            Please use the following 6-digit code to complete your admin login. 
            This code will expire in <strong>5 minutes</strong>.
          </p>
          
          <!-- OTP Code Box -->
          <div style="background: #f8f9fa; border: 2px dashed #667eea; border-radius: 12px; padding: 20px; text-align: center; margin: 30px 0;">
            <span style="font-size: 48px; font-weight: bold; letter-spacing: 8px; color: #667eea; font-family: monospace;">
              $otpCode
            </span>
          </div>
          
          <!-- Security Notice -->
          <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 30px 0; border-radius: 4px;">
            <p style="color: #856404; margin: 0; font-size: 14px;">
              <strong>⚠️ Security Notice:</strong> Never share this OTP with anyone. 
              Our team will never ask for your OTP.
            </p>
          </div>
          
          <!-- Divider -->
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          
          <!-- Footer -->
          <p style="color: #999; font-size: 12px; text-align: center; margin: 0;">
            If you didn't request this code, please ignore this email.<br>
            © 2024 CPB AI Vision. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }
  
  // Plain text email template (for email clients that don't support HTML)
  static String _buildOtpEmailText(String otpCode) {
    return '''
CPB AI Vision - Admin Login Verification

Your One-Time Password (OTP) is: $otpCode

This code will expire in 5 minutes.

Security Notice: Never share this OTP with anyone. Our team will never ask for your OTP.

If you didn't request this code, please ignore this email.

© 2024 CPB AI Vision. All rights reserved.
    ''';
  }
  
  // For testing - send test email
  static Future<void> sendTestEmail(String toEmail) async {
    print('🧪 Sending test email to $toEmail...');
    await sendOtpEmail(toEmail, '123456');
  }
}