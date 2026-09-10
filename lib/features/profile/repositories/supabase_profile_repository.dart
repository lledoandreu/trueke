import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/profile/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String id);
  Future<void> updateProfile(UserProfile profile);
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  @override
  Future<UserProfile> getProfile(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final updates = profile.toJson();
    updates.remove('created_at');
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('profiles').update(updates).eq('id', profile.id);
  }
}
