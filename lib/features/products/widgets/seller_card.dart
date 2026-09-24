import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';
import '../../profile/providers/profile_provider.dart';
import '../../transactions/presentation/pages/user_reviews_screen.dart';

class SellerCard extends ConsumerWidget {
  final Product product;

  const SellerCard({super.key, required this.product});

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar =
        (rating - fullStars) >= 0.25 && (rating - fullStars) < 0.75;
    if ((rating - fullStars) >= 0.75) fullStars++;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerId = product.ownerId ?? '';
    final profileAsync = ref.watch(userProfileProvider(sellerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendedor',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: const Color(0xFFF8F9FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: profileAsync.when(
            data: (profile) {
              final avatarUrl = profile.avatarUrl;
              final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFD9F8E5),
                  backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  child: hasAvatar
                      ? null
                      : const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        ),
                ),
                title: Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : product.owner,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Miembro verificado',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(profile.averageRating),
                          const SizedBox(width: 6),
                          Text(
                            '${profile.averageRating.toStringAsFixed(1)} (${profile.totalRatings})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserReviewsScreen(
                            userId: profile.id,
                            userName: profile.displayName,
                          ),
                        ),
                      )
                      .then(
                        (_) => ref.invalidate(userProfileProvider(sellerId)),
                      );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => ListTile(
              title: Text(product.owner),
              subtitle: const Text('Error al cargar reputación'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }
}
