import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_review.dart';
import '../repositories/reviews_repository.dart';
import '../../../core/supabase/supabase_client.dart';

final reviewsRepositoryProvider = Provider.autoDispose<ReviewsRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseReviewsRepository(client);
});

final userReviewsProvider = FutureProvider.family
    .autoDispose<List<UserReview>, String>((ref, userId) async {
      final repository = ref.watch(reviewsRepositoryProvider);
      return repository.getUserReviews(userId);
    });
