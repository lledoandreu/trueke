import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Profile?> getMyProfile(String userId) async {
    try {
      print('GET PROFILE START: $userId');

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      print('PROFILE QUERY OK');
      print('GET PROFILE RESPONSE: $response');

      if (response == null) {
        return null;
      }

      return Profile.fromMap(response);
    } catch (e, st) {
      print('PROFILE ERROR: $e');
      print(st);
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
      print('UPDATE PROFILE START: ${profile.id}');
      print('UPDATE DATA: ${profile.toMap()}');

      final response = await _client
          .from('profiles')
          .update(profile.toMap())
          .eq('id', profile.id)
          .select()
          .single();

      print('UPDATE PROFILE OK: $response');
    } catch (e, st) {
      print('UPDATE PROFILE ERROR: $e');
      print(st);
      rethrow;
    }
  }
}
