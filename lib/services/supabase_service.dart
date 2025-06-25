import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://pjeolvtjssuqgesfejzh.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqZW9sdnRqc3N1cWdlc2ZlanpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1Mjg2MDcsImV4cCI6MjA2NjEwNDYwN30.1Gn3raU_OHfwYNBWbr8pyMDVVnA1Ki4PS0wmqUsRJQk',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}