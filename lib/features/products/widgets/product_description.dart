import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  const ProductDescription({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Text(
          product.description,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ],
    );
  }
}
