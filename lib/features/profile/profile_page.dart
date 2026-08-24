import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/favorites_provider.dart';
import '../auth/auth_service.dart';
import '../products/providers/products_provider.dart';
import '../trades/providers/trade_offers_provider.dart';
import '../trades/trade_offers_page.dart';
import 'edit_profile_page.dart';
import 'my_listings_page.dart';
import 'providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = AuthService.currentUser;
    final profileAsync = ref.watch(profileProvider);
    final productsAsync = ref.watch(productsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final offersAsync = ref.watch(tradeOffersProvider);

    final listingCount =
        productsAsync.valueOrNull
            ?.where((product) => product.ownerId == user?.id)
            .length ??
        0;

    final favoriteCount = favoritesAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: profileAsync.when(
              loading: () => const CircleAvatar(
                radius: 42,
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => const CircleAvatar(
                radius: 42,
                child: Icon(Icons.person, size: 44),
              ),
              data: (profile) => CircleAvatar(
                radius: 42,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person, size: 44)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          profileAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, _) => Text(user?.email ?? 'Tu perfil'),
            data: (profile) {
              final name =
                  profile?.displayName ??
                  profile?.username ??
                  user?.email ??
                  'Tu perfil';

              return Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile?.username != null)
                    Text('@${profile!.username}'),
                  if (profile != null)
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfilePage(profile: profile),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Anuncios',
                  value: '$listingCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Favoritos',
                  value: '$favoriteCount',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Mis anuncios'),
              subtitle: const Text(
                'Consulta, edita o elimina artículos publicados',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyListingsPage(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Mis propuestas'),
              subtitle: Text(
                '${offersAsync.valueOrNull?.length ?? 0} enviadas',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TradeOffersPage(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              subtitle: const Text(
                'Volverás a la pantalla de acceso',
              ),
              onTap: () async {
                await AuthService.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
