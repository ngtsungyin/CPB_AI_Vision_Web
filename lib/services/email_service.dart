import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  // Change this to your backend URL when running
  static const String _backendUrl = 'http://localhost:3001'; // Local dev
  
  // For testing - set to false when backend is ready
  static bool _testMode = false;
  
  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    print('📧 Email Service: Sending OTP $otpCode to $toEmail');
    
    // TEST MODE - Just print to console
    if (_testMode) {
      print('==========================================');
      print('🔧 TEST MODE - USE THIS OTP: $otpCode');
      print('📧 EMAIL: $toEmail');
      print('==========================================');
      return true;
    }
    
    // PRODUCTION MODE - Call your backend
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': toEmail,
          'otp': otpCode,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Email sent via backend: ${data['messageId']}');
        return true;
      } else {
        print('❌ Backend error: ${response.body}');
        return false;
      }
        } catch (e) {
      print('❌ Failed to call backend: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      // Add more details if it's a specific error type
      if (e is http.ClientException) {
        print('❌ ClientException details: ${e.message}');
        print('❌ ClientException URI: ${e.uri}');
      }
      
      print('==========================================');
      print('🔑 FALLBACK OTP: $otpCode');
      print('==========================================');
      return false;
    }
  }
}