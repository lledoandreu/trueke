import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';
import '../../models/user_review.dart';

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
    await _client.from('profiles').insert(profile.toMap());
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

  Future<List<UserReview>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('user_reviews')
          .select()
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => UserReview.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  }) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) throw Exception('Debes iniciar sesión.');

    final myProfileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', myId)
        .maybeSingle();
    final myName = myProfileResponse != null
        ? (myProfileResponse['display_name'] ??
              myProfileResponse['username'] ??
              'Usuario')
        : 'Usuario';
    final myAvatar = myProfileResponse != null
        ? (myProfileResponse['avatar_url'] ?? '')
        : '';

    await _client.from('user_reviews').insert({
      'reviewer_id': myId,
      'reviewer_name': myName,
      'reviewer_avatar': myAvatar,
      'receiver_id': receiverId,
      'rating': rating,
      'comment': comment,
    });
  }
}
