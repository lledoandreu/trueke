import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import 'products_provider.dart';

class ProductFilters {
  const ProductFilters({this.query = '', this.category, this.tradeType});

  final String query;
  final String? category;
  final TradeType? tradeType;

  bool get hasActiveFilters =>
      query.isNotEmpty || category != null || tradeType != null;

  ProductFilters copyWith({
    String? query,
    String? category,
    TradeType? tradeType,
    bool clearCategory = false,
    bool clearTradeType = false,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      tradeType: clearTradeType ? null : tradeType ?? this.tradeType,
    );
  }
}

class ProductFiltersNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setQuery(String query) {
    state = state.copyWith(query: query.trim());
  }

  void toggleCategory(String category) {
    state = state.copyWith(
      category: state.category == category ? null : category,
      clearCategory: state.category == category,
    );
  }

  void clearCategory() {
    state = state.copyWith(clearCategory: true);
  }

  void setTradeType(TradeType? tradeType) {
    state = state.copyWith(
      tradeType: tradeType,
      clearTradeType: tradeType == null,
    );
  }

  void clear() => state = const ProductFilters();
}

final productFiltersProvider =
    NotifierProvider<ProductFiltersNotifier, ProductFilters>(
      ProductFiltersNotifier.new,
    );

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final filters = ref.watch(productFiltersProvider);
  final normalizedQuery = filters.query.toLowerCase();

  return products.whenData(
    (items) => items.where((product) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          [
            product.title,
            product.description,
            product.category,
            product.location,
            product.owner,
          ].any((value) => value.toLowerCase().contains(normalizedQuery));
      final matchesCategory =
          filters.category == null || product.category == filters.category;
      final matchesTradeType =
          filters.tradeType == null || product.tradeType == filters.tradeType;

      return matchesQuery && matchesCategory && matchesTradeType;
    }).toList(),
  );
});
