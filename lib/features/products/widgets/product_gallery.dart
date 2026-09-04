import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/favorites_provider.dart';
import '../../../models/product.dart';

class ProductGallery extends ConsumerWidget {
  final Product product;

  const ProductGallery({super.key, required this.product});

  Widget _buildImage() {
    if (product.images.isEmpty) {
      return Container(
        color: const Color(0xFFF2F3F5),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Image.network(
      product.images.first,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.image_not_supported, size: 60));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final isFavorite = favoritesState.maybeWhen(
      data: (favs) => favs.any((item) => item.id == product.id),
      orElse: () => false,
    );

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(background: _buildImage()),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(product);
          },
        ),
      ],
    );
  }
}
