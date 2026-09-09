import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../home/widgets/product_card.dart';
import '../home/widgets/search_bar_widget.dart';
import '../products/providers/product_filters_provider.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final filters = ref.watch(productFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          if (filters.hasActiveFilters)
            TextButton(
              onPressed: () =>
                  ref.read(productFiltersProvider.notifier).clear(),
              child: const Text('Limpiar'),
            ),
        ],
      ),
      body: Column(
        children: [
          const SearchBarWidget(),
          _FilterChips(filters: filters),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se han podido cargar los productos.\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hemos encontrado artículos con esos filtros.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 4 : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.55,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filters});

  final ProductFilters filters;

  static const _availableCategories = [
    'Electrónica',
    'Moda',
    'Hogar',
    'Gaming',
    'Deporte',
    'Otros',
  ];

  String _tradeTypeLabel(TradeType type) {
    switch (type) {
      case TradeType.trade:
        return 'Trueque';
      case TradeType.sale:
        return 'Venta';
      case TradeType.tradeAndMoney:
        return 'Trueque + €';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productFiltersProvider.notifier);

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          // Filtros por Tipo de Trueque
          for (final type in TradeType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: filters.tradeType == type,
                label: Text(_tradeTypeLabel(type)),
                onSelected: (_) => notifier.setTradeType(
                  filters.tradeType == type ? null : type,
                ),
              ),
            ),

          const VerticalDivider(width: 16, indent: 8, endIndent: 8),

          // Filtros por Categoría
          for (final cat in _availableCategories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: filters.category == cat,
                label: Text(cat),
                onSelected: (_) => notifier.toggleCategory(cat),
              ),
            ),
        ],
      ),
    );
  }
}
