import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductGallery extends StatelessWidget {
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
        return const Icon(Icons.image_not_supported);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(background: _buildImage()),
      actions: [
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
      ],
    );
  }
}
