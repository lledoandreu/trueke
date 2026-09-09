import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/user_review.dart';
import 'package:trueke/features/transactions/repositories/reviews_repository.dart';
import 'package:trueke/features/transactions/providers/reviews_provider.dart';
import 'package:trueke/features/transactions/presentation/widgets/user_reviews_list_widget.dart';

class FakeReviewsListRepository implements ReviewsRepository {
  @override
  Future<List<UserReview>> getUserReviews(String userId) async => [];

  @override
  Future<void> addReview({
    required String reviewerId,
    required String reviewerName,
    required String reviewerAvatar,
    required String receiverId,
    required double rating,
    required String comment,
  }) async {}
}

void main() {
  const targetUserId = 'user_123';

  testWidgets(
    'Debe mostrar un indicador de carga cuando el proveedor está en loading',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: UserReviewsListWidget(userId: targetUserId)),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'Debe mostrar el mensaje de ausencia de valoraciones cuando la lista está vacía',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reviewsRepositoryProvider.overrideWithValue(
              FakeReviewsListRepository(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: UserReviewsListWidget(userId: targetUserId)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Este usuario aún no tiene valoraciones.'),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsNothing);
    },
  );
}
