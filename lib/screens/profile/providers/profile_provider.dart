import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile(user.id);

      // If no profile exists, create one
      if (_profile == null) {
        await _profileService.createProfile(
          user.id,
          fullName: user.userMetadata?['full_name'],
          email: user.email,
        );
        _profile = await _profileService.getProfile(user.id);
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = Profile(
        id: _profile!.id,
        fullName: fullName ?? _profile!.fullName,
        avatarUrl: avatarUrl ?? _profile!.avatarUrl,
        bio: bio ?? _profile!.bio,
        updatedAt: DateTime.now(),
      );

      final success = await _profileService.updateProfile(updatedProfile);
      if (success) {
        _profile = updatedProfile;
      } else {
        _error = 'Failed to update profile';
      }

      return success;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
