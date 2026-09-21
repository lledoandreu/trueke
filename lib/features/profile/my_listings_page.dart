import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes/app_routes.dart';
import '../../models/product.dart';
import '../products/providers/products_provider.dart';
import '../products/publish_product_page.dart';

class MyListingsPage extends ConsumerWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis anuncios')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Error cargando tus anuncios',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(productsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productsProvider);
                await ref.read(productsProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Todavía no has publicado ningún artículo.\n\n'
                      'Usa la pestaña Publicar para crear tu primer anuncio.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
              await ref.read(productsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = listings[index];

                return _ListingCard(
                  product: product,
                  onEdit: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PublishProductPage(product: product),
                      ),
                    );

                    ref.invalidate(productsProvider);
                  },
                  onDelete: () => _confirmDelete(context, ref, product),
                );
              },
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(productsProvider.notifier).deleteProduct(product);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anuncio eliminado correctamente.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el anuncio: $error')),
      );
    }
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.product, arguments: product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumbnail(product: product),
              const SizedBox(width: 12),
              Expanded(child: _ProductInfo(product: product)),
              const SizedBox(width: 4),
              Column(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});

  final Product product;

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tecnología':
      case 'electronics':
        return Icons.devices;
      case 'ropa':
      case 'fashion':
        return Icons.checkroom;
      case 'hogar':
      case 'home':
        return Icons.home_max;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.isEmpty) {
      return Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _categoryIcon(product.category),
          size: 36,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        product.imageUrl,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 92,
            height: 92,
            color: const Color(0xFFF2F3F5),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 92,
            height: 92,
            color: const Color(0xFFF2F3F5),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          product.category,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        if (product.wanted.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Busca: ${product.wanted}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
