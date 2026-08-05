import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'widgets/product_description.dart';
import 'widgets/product_info.dart';
import 'widgets/seller_card.dart';
import 'widgets/trade_info.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Proponer intercambio'),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(product.imageUrl, fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfo(product: product),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 24),

                  TradeInfo(product: product),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 24),

                  SellerCard(product: product),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  ProductDescription(product: product),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
