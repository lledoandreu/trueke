import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../profile_repository.dart';
import '../../../models/user_review.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final userReviewsProvider = FutureProvider.family<List<UserReview>, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserReviews(userId);
});
