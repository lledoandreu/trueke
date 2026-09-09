import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/user_review.dart';
import 'package:trueke/features/transactions/repositories/reviews_repository.dart';
import 'package:trueke/features/transactions/providers/reviews_provider.dart';

class FakeReviewsRepository implements ReviewsRepository {
  final List<UserReview> reviewsList = [];
  bool throwsError = false;

  @override
  Future<List<UserReview>> getUserReviews(String userId) async {
    if (throwsError) throw Exception('Database error');
    return reviewsList;
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
    if (throwsError) throw Exception('Insert error');
  }
}

void main() {
  late FakeReviewsRepository fakeRepository;
  late ProviderContainer container;
  const targetUserId = 'user_123';

  setUp(() {
    fakeRepository = FakeReviewsRepository();
    container = ProviderContainer(
      overrides: [reviewsRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'Debe inicializar con AsyncLoading y luego cambiar a AsyncData con la lista de reseñas',
    () async {
      final subscription = container.listen(
        userReviewsProvider(targetUserId),
        (previous, next) {},
        fireImmediately: true,
      );

      expect(subscription.read(), const AsyncValue<List<UserReview>>.loading());

      await container.read(userReviewsProvider(targetUserId).future);

      expect(subscription.read().value, isEmpty);
      subscription.close();
    },
  );

  test(
    'Debe refrescar correctamente el estado local tras añadir una reseña con addReview',
    () async {
      await container.read(userReviewsProvider(targetUserId).future);

      final notifier = container.read(
        userReviewsProvider(targetUserId).notifier,
      );

      await notifier.addReview(
        reviewerId: 'reviewer_abc',
        reviewerName: 'David',
        reviewerAvatar: 'avatar.png',
        rating: 5.0,
        comment: 'Excelente trueque, muy recomendado.',
      );

      final state = container.read(userReviewsProvider(targetUserId));
      expect(state.hasValue, isTrue);
      expect(state.isLoading, isFalse);
    },
  );
}
