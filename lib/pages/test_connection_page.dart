import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestConnectionPage extends StatefulWidget {
  @override
  _TestConnectionPageState createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _status = 'Click the button to test connection';

  Future<void> _testConnection() async {
    try {
      setState(() {
        _status = 'Connecting...';
      });

      final supabase = Supabase.instance.client;
      
      // Test with a table that doesn't have recursive policies
      // Try farms table first, or any other table
      await supabase.from('farms').select().limit(1);
      
      setState(() {
        _status = '✅ Connected to Supabase successfully!';
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Test'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _testConnection,
              child: Text('Test Supabase Connection'),
            ),
          ],
        ),
      ),
    );
  }
}