import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseSupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  void logError(String context, Object error) {
    // Better than repeating print everywhere
    // You can later replace this with debugPrint or a logger
    print('$context: $error');
  }
}