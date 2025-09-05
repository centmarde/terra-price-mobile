import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> updateProfile(Profile profile) async {
    try {
      await _supabase
          .from('profiles')
          .upsert(profile.toJson())
          .eq('id', profile.id);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> createProfile(
    String userId, {
    String? fullName,
    String? email,
  }) async {
    try {
      final profile = Profile(
        id: userId,
        fullName: fullName ?? email?.split('@').first ?? 'User',
      );

      await _supabase.from('profiles').insert(profile.toJson());
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }
}
