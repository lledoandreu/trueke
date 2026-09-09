import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/location_service.dart';
import '../../models/product.dart';
import '../home/widgets/product_card.dart';
import '../home/widgets/search_bar_widget.dart';
import '../products/providers/product_filters_provider.dart';
import 'widgets/search_map_view.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final filters = ref.watch(productFiltersProvider);

    final bool hasActive = filters.hasActiveFilters;
    final double? userLat = filters.userLatitude;
    final double? userLng = filters.userLongitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.grid_view : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          if (hasActive)
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
          if (userLat != null) _RadiusSlider(filters: filters),
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
              data: (List<Product> products) {
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

                if (_isMapView) {
                  return SearchMapView(
                    products: products,
                    centerLatitude: userLat,
                    centerLongitude: userLng,
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

class _RadiusSlider extends ConsumerWidget {
  const _RadiusSlider({required this.filters});

  final ProductFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRadius = filters.radiusInKm ?? 50.0;
    final double? userLat = filters.userLatitude;
    final double? userLng = filters.userLongitude;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('Radio: ${currentRadius.round()} km'),
          Expanded(
            child: Slider(
              value: currentRadius,
              min: 5,
              max: 150,
              divisions: 29,
              label: '${currentRadius.round()} km',
              onChanged: (double value) {
                if (userLat != null && userLng != null) {
                  ref
                      .read(productFiltersProvider.notifier)
                      .setGeoFilter(
                        latitude: userLat,
                        longitude: userLng,
                        radiusInKm: value,
                      );
                }
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
    final bool hasGeo = filters.userLatitude != null;

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            key: const Key('geo_filter_chip'),
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: const Icon(Icons.gps_fixed, size: 16),
              selected: hasGeo,
              label: const Text('Cerca de mí'),
              onSelected: (bool selected) async {
                if (selected) {
                  final position = await LocationService().getCurrentLocation();
                  if (position != null) {
                    notifier.setGeoFilter(
                      latitude: position.latitude,
                      longitude: position.longitude,
                      radiusInKm: 50.0,
                    );
                  }
                } else {
                  notifier.clearGeoFilter();
                }
              },
            ),
          ),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
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
