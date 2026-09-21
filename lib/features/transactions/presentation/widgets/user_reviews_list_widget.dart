import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reviews_provider.dart';

class UserReviewsListWidget extends ConsumerWidget {
  final String userId;

  const UserReviewsListWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(userReviewsProvider(userId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Este usuario aún no tiene valoraciones.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final avatarUrl = review.reviewerAvatar;

            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName
                            : 'Anónimo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(review.comment),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Error al cargar las valoraciones',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
