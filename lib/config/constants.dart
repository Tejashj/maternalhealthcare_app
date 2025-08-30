import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'default_url';
  static final String supabaseAnonKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'default_key';
}

class AppwriteConstants {
  static const String endpoint =
      'https://cloud.appwrite.io/v1'; // Your API endpoint
}
