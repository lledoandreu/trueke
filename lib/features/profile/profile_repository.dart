import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Profile?> getMyProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (response == null) {
        return null;
      }

      return Profile.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProfile(Profile profile) async {
    await _client
        .from('profiles')
        .insert(profile.toMap());
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await _client
          .from('profiles')
          .update(profile.toMap())
          .eq('id', profile.id)
          .select()
          .single();
    } catch (e) {
      rethrow;
    }
  }
}
