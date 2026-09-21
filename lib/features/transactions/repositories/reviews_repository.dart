import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_review.dart';

abstract class ReviewsRepository {
  Future<List<UserReview>> getUserReviews(String userId);
  Future<void> addReview({
    required String reviewerId,
    required String reviewerName,
    required String reviewerAvatar,
    required String receiverId,
    required double rating,
    required String comment,
  });
}

class SupabaseReviewsRepository implements ReviewsRepository {
  SupabaseReviewsRepository(this._client);

  final SupabaseClient _client;
  static const _tableName = 'user_reviews';

  @override
  Future<List<UserReview>> getUserReviews(String userId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => UserReview.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addReview({
    required String reviewerId,
    required String reviewerName,
    required String reviewerAvatar,
    required String receiverId,
    required double rating,
    required String comment,
  }) async {
    await _client.from(_tableName).insert({
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_avatar': reviewerAvatar,
      'receiver_id': receiverId,
      'rating': rating,
      'comment': comment.trim(),
    });
  }
}
