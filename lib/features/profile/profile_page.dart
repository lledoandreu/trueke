import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/favorites/favorites_page.dart';
import 'package:trueke/features/trades/providers/trade_offers_provider.dart';
import 'package:trueke/features/trades/trade_offers_page.dart';
import 'package:trueke/features/profile/edit_profile_page.dart';
import 'package:trueke/features/profile/my_listings_page.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
            onPressed: () async {
              await AuthService.signOut();
            },
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
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
