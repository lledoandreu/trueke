import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/favorites_provider.dart';
import '../auth/auth_service.dart';
import '../products/providers/products_provider.dart';
import 'my_listings_page.dart';
import '../trades/providers/trade_offers_provider.dart';
import '../trades/trade_offers_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = AuthService.currentUser;
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
          const Center(
            child: CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 44),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.email ?? 'Tu perfil',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Center(child: Text('Sesión iniciada')),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _StatCard(label: 'Anuncios', value: '$listingCount'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(label: 'Favoritos', value: '$favoriteCount'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Mis anuncios'),
              subtitle: const Text('Consulta o elimina artículos publicados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyListingsPage())),
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
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TradeOffersPage()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              subtitle: const Text('Volverás a la pantalla de acceso'),
              onTap: () async {
                try {
                  await AuthService.signOut();
                } on Exception catch (_) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se ha podido cerrar la sesión.'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
