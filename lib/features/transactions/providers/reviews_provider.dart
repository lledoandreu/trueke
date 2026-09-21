import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_review.dart';
import '../repositories/reviews_repository.dart';

// Proveedor del repositorio inyectando el cliente de Supabase
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return SupabaseReviewsRepository(Supabase.instance.client);
});

class UserReviewsNotifier extends AsyncNotifier<List<UserReview>> {
  final String userId;

  UserReviewsNotifier(this.userId);

  @override
  FutureOr<List<UserReview>> build() async {
    final repository = ref.read(reviewsRepositoryProvider);
    return repository.getUserReviews(userId);
  }

  /// Añade una nueva reseña pasando los parámetros requeridos por la firma del repositorio.
  /// Tras la inserción exitosa, muta el estado local de forma reactiva optimista.
  Future<void> addReview({
    required String reviewerId,
    required String reviewerName,
    required String reviewerAvatar,
    required double rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reviewsRepositoryProvider);

      // Inserción en la base de datos distribuida de Supabase
      await repository.addReview(
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        reviewerAvatar: reviewerAvatar,
        receiverId: userId,
        rating: rating,
        comment: comment,
      );

      // Refrescamos los datos directamente del repositorio para garantizar consistencia total (IDs generados, fechas por defecto, etc.)
      return repository.getUserReviews(userId);
    });
  }
}

// Configuración manual del proveedor familiar asíncrono con autodescarte
final userReviewsProvider = AsyncNotifierProvider.autoDispose
    .family<UserReviewsNotifier, List<UserReview>, String>(
      UserReviewsNotifier.new,
    );
