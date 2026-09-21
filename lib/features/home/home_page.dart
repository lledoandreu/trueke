import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../products/providers/product_filters_provider.dart';
import 'widgets/category_chip.dart';
import 'widgets/home_header.dart';
import 'widgets/product_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/search_bar_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final filters = ref.watch(productFiltersProvider);

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

            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CategoryChip(
                        icon: Icons.phone_iphone,
                        label: 'Electrónica',
                        selected: filters.category == 'Electrónica',
                        onTap: () => ref
                            .read(productFiltersProvider.notifier)
                            .toggleCategory('Electrónica'),
                      ),
                      CategoryChip(
                        icon: Icons.checkroom,
                        label: 'Moda',
                        selected: filters.category == 'Moda',
                        onTap: () => ref
                            .read(productFiltersProvider.notifier)
                            .toggleCategory('Moda'),
                      ),
                      CategoryChip(
                        icon: Icons.chair,
                        label: 'Hogar',
                        selected: filters.category == 'Hogar',
                        onTap: () => ref
                            .read(productFiltersProvider.notifier)
                            .toggleCategory('Hogar'),
                      ),
                      CategoryChip(
                        icon: Icons.sports_esports,
                        label: 'Gaming',
                        selected: filters.category == 'Gaming',
                        onTap: () => ref
                            .read(productFiltersProvider.notifier)
                            .toggleCategory('Gaming'),
                      ),
                      CategoryChip(
                        icon: Icons.directions_bike,
                        label: 'Deporte',
                        selected: filters.category == 'Deporte',
                        onTap: () => ref
                            .read(productFiltersProvider.notifier)
                            .toggleCategory('Deporte'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  filters.hasActiveFilters ? 'Resultados' : 'Recomendados',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No hemos encontrado artículos con esos filtros.',
                        ),
                      ),
                    ),
                  );
                }
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
    );
  }
}
