import 'package:flutter/material.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/app/routes/app_routes.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (product.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ubicación: ${product.location}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(product.description),
          if (product.wanted.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Lo que el dueño busca a cambio:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Text(product.wanted),
          ],
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.sendTradeOffer,
                arguments: product,
              );
            },
            icon: const Icon(Icons.swap_horizontal_circle_rounded),
            label: const Text('Proponer Trueque'),
          ),
        ],
      ),
    );
  }
}
