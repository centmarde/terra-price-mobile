import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration constants
/// Contains the URL and anonymous key for Supabase integration
class SupabaseConstants {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://gqxhltrjxuiuyveiqtsf.supabase.co';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGhsdHJqeHVpdXl2ZWlxdHNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NTQwNjEsImV4cCI6MjA3MjIzMDA2MX0.zAvFfCafNfRci6HrMGXd2Fi6wcwMUf-JfWMsHUYa19E';
  static String get supabaseServiceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxeGhsdHJqeHVpdXl2ZWlxdHNmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjY1NDA2MSwiZXhwIjoyMDcyMjMwMDYxfQ.DP47AEgmGg9vdXmsL5jsYf-6Cpyoj2QRf-zXKp6JYiU';
}
