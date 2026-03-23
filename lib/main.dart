// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/admin_login.dart';
import 'pages/admin_panel.dart';
import 'pages/auth_callback.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase (for database operations only)
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocoa Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // Add routes here
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminLoginPage(),
        '/auth/callback': (context) => const AuthCallbackPage(),
        '/admin': (context) => const AdminPanel(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}