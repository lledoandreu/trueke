import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import '../../../models/user_review.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String id);
  Future<void> updateProfile(UserProfile profile);
  Future<List<UserReview>> getUserReviews(String userId);
  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  });
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

  @override
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

  @override
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
