import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/favorites_provider.dart';
import '../../models/product.dart';
import 'widgets/product_description.dart';
import 'widgets/product_info.dart';
import 'widgets/seller_card.dart';
import 'widgets/trade_info.dart';
import '../trades/send_trade_offer_page.dart';

class ProductDetailPage extends ConsumerWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  Widget _buildProductImage() {
    if (product.imageUrl.isEmpty) {
      return Container(
        height: 420,
        width: double.infinity,
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

    return SizedBox(
      height: 420,
      width: double.infinity,
      child: Image.asset(product.imageUrl, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider.notifier);
    final isFavorite = favorites.isFavorite(product);

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SendTradeOfferPage(product: product),
              ),
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Proponer intercambio'),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                _buildProductImage(),

                Positioned(
                  top: 45,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: 45,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(product);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
