import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/favorites/favorites_page.dart';
import 'package:trueke/features/trades/providers/trade_offers_provider.dart';
import 'package:trueke/features/trades/trade_offers_page.dart';
import 'package:trueke/features/profile/edit_profile_page.dart';
import 'package:trueke/features/profile/my_listings_page.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/profile/providers/reviews_provider.dart';
import '../../app/routes/app_routes.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _buildStars(double rating) {
    final intFullStars = rating.floor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < intFullStars ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: 20,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final tradeOffersAsync = ref.watch(tradeOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async => AuthService.signOut(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error al cargar perfil: $error')),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('No se encontró información del perfil.'),
            );
          }
          final nameLabel =
              profile.displayName ?? profile.username ?? 'Usuario';
          final reviewsAsync = ref.watch(userReviewsProvider(profile.id));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent.withAlpha(25),
                      backgroundImage:
                          profile.avatarUrl != null &&
                              profile.avatarUrl!.isNotEmpty
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child:
                          profile.avatarUrl == null ||
                              profile.avatarUrl!.isEmpty
                          ? Text(
                              nameLabel.isNotEmpty
                                  ? nameLabel.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nameLabel,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile.username ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.reviews,
                        arguments: profile.id,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: reviewsAsync.when(
                          loading: () => const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, err) => const SizedBox.shrink(),
                          data: (reviews) {
                            if (reviews.isEmpty) {
                              return const Text(
                                'Sin valoraciones aún',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            final totalRating = reviews
                                .map((r) => r.rating)
                                .reduce((a, b) => a + b);
                            final averageRating = totalRating / reviews.length;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStars(averageRating),
                                const SizedBox(width: 6),
                                Text(
                                  '${averageRating.toStringAsFixed(1)} (${reviews.length})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                  color: Colors.blueAccent,
                ),
                title: const Text('Editar Perfil'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfilePage(profile: profile),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Colors.blueAccent,
                ),
                title: const Text('Mis Artículos Publicados'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const MyListingsPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.swap_horizontal_circle_rounded,
                  color: Colors.blueAccent,
                ),
                title: const Text('Mis Propuestas de Intercambio'),
                trailing: tradeOffersAsync.when(
                  data: (offers) {
                    final pending = offers
                        .where((o) => o.isPending && o.isIncoming)
                        .length;
                    return pending > 0
                        ? Badge(
                            label: Text('$pending'),
                            child: const Icon(Icons.chevron_right_rounded),
                          )
                        : const Icon(Icons.chevron_right_rounded);
                  },
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const Icon(Icons.chevron_right_rounded),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const TradeOffersPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text('Mis Favoritos'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const FavoritesPage(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
