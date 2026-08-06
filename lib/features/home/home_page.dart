import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../products/providers/products_provider.dart';
import 'widgets/category_chip.dart';
import 'widgets/home_header.dart';
import 'widgets/product_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/search_bar_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    final width = MediaQuery.of(context).size.width;

    final int crossAxisCount;

    if (width < 700) {
      crossAxisCount = 2;
    } else if (width < 1000) {
      crossAxisCount = 3;
    } else if (width < 1400) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),

            const SliverToBoxAdapter(child: SearchBarWidget()),

            const SliverToBoxAdapter(child: PromoBanner()),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Categorías',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CategoryChip(
                        icon: Icons.phone_iphone,
                        label: 'Electrónica',
                      ),
                      CategoryChip(icon: Icons.checkroom, label: 'Moda'),
                      CategoryChip(icon: Icons.chair, label: 'Hogar'),
                      CategoryChip(icon: Icons.sports_esports, label: 'Gaming'),
                      CategoryChip(
                        icon: Icons.directions_bike,
                        label: 'Deporte',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Recomendados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            productsAsync.when(
              loading: () {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
              error: (error, stackTrace) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('Error cargando productos: $error'),
                    ),
                  ),
                );
              },
              data: (products) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductCard(product: products[index]);
                    }, childCount: products.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
;
  }
}
