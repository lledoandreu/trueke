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
              onPressed: ref.read(productFiltersProvider.notifier).clear,
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
              error: (error, stackTrace) =>
                  Center(child: Text('Error cargando productos: $error')),
              data: (products) => products.isEmpty
                  ? const Center(
                      child: Text(
                        'No hemos encontrado artículos con esos filtros.',
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 700 ? 3 : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.62,
                              ),
                          itemBuilder: (context, index) =>
                              ProductCard(product: products[index]),
                        );
                      },
                    ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todas las categorías'),
            selected: filters.category == null,
            onSelected: (_) =>
                ref.read(productFiltersProvider.notifier).clearCategory(),
          ),
          const SizedBox(width: 8),
          for (final category in const [
            'Electrónica',
            'Moda',
            'Hogar',
            'Gaming',
            'Deporte',
          ]) ...[
            FilterChip(
              label: Text(category),
              selected: filters.category == category,
              onSelected: (_) => ref
                  .read(productFiltersProvider.notifier)
                  .toggleCategory(category),
            ),
            const SizedBox(width: 8),
          ],
          for (final option in TradeType.values) ...[
            FilterChip(
              label: Text(_tradeTypeLabel(option)),
              selected: filters.tradeType == option,
              onSelected: (selected) => ref
                  .read(productFiltersProvider.notifier)
                  .setTradeType(selected ? option : null),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  String _tradeTypeLabel(TradeType type) {
    return switch (type) {
      TradeType.trade => 'Trueque',
      TradeType.sale => 'Venta',
      TradeType.tradeAndMoney => 'Trueque + €',
    };
  }
}
