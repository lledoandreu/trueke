import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/providers/reviews_provider.dart';

class ReviewsPage extends ConsumerWidget {
  const ReviewsPage({super.key, required this.userId});
  final String userId;

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: 16,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(userReviewsProvider(userId));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Valoraciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error al cargar valoraciones: $err')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                'Este usuario aún no tiene valoraciones.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final initial = review.reviewerName.isNotEmpty
                  ? review.reviewerName.substring(0, 1).toUpperCase()
                  : '?';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent.withAlpha(25),
                    backgroundImage: review.reviewerAvatar.isNotEmpty
                        ? NetworkImage(review.reviewerAvatar)
                        : null,
                    child: review.reviewerAvatar.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.reviewerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            _buildStars(review.rating),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.comment,
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
