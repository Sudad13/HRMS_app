import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.get('SUPABASE_URL');
  static String get key => dotenv.get('SUPABASE_KEY');
}