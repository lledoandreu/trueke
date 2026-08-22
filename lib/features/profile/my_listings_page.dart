import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../auth/auth_service.dart';
import '../products/publish_product_page.dart';
import '../products/providers/products_provider.dart';

class MyListingsPage extends ConsumerWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final currentUserId = AuthService.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis anuncios')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error cargando anuncios: $error')),
        data: (products) {
          final listings = products
              .where((product) => product.ownerId == currentUserId)
              .toList();

          if (listings.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Todavía no has publicado ningún artículo.\nUsa la pestaña Publicar para crear tu primer anuncio.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _ListingTile(
              product: listings[index],
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublishProductPage(product: listings[index]),
                ),
              ),
              onDelete: () => _confirmDelete(context, ref, listings[index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar anuncio'),
        content: Text('¿Quieres eliminar “${product.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(productsProvider.notifier).deleteProduct(product.id);
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F3F5),
          child: Icon(_categoryIcon(product.category)),
        ),
        title: Text(product.title),
        subtitle: Text('${product.condition} · ${product.location}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar anuncio',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar anuncio',
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Electrónica' => Icons.devices_outlined,
      'Moda' => Icons.checkroom_outlined,
      'Hogar' => Icons.chair_outlined,
      'Gaming' => Icons.sports_esports_outlined,
      'Deporte' => Icons.directions_bike_outlined,
      _ => Icons.inventory_2_outlined,
    };
  }
}
