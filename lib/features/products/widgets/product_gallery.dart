import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductGallery extends StatelessWidget {
  final Product product;

  const ProductGallery({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(product.imageUrl, fit: BoxFit.cover),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
      ],
    );
  }
}
