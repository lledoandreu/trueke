import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/favorite_provider.dart';
import '../auth/auth_service.dart';
import '../home/widgets/product_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: authUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error de autenticación: $error')),
        data: (userId) {
          if (userId == null) {
            return const Center(
              child: Text(
                'Inicia sesión para ver tus favoritos',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final favoriteProductsAsync = ref.watch(
            favoriteProductsProvider(userId),
          );

          return favoriteProductsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Error cargando favoritos: $error')),
            data: (favorites) {
              if (favorites.isEmpty) {
                return const Center(
                  child: Text(
                    'No tienes productos favoritos',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: favorites[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
