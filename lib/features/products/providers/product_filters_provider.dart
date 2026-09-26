import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import 'product_repository_provider.dart';

enum ProductSortOption { relevance, priceAsc, priceDesc, distance }

class ProductFilters {
  const ProductFilters({
    this.query = '',
    this.category,
    this.tradeType,
    this.userLatitude,
    this.userLongitude,
    this.radiusInKm = 50.0,
    this.sortBy = ProductSortOption.relevance,
    this.minPrice,
    this.maxPrice,
    this.condition,
  });

  final String query;
  final String? category;
  final TradeType? tradeType;
  final double? userLatitude;
  final double? userLongitude;
  final double radiusInKm;
  final ProductSortOption sortBy;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      category != null ||
      tradeType != null ||
      sortBy != ProductSortOption.relevance ||
      minPrice != null ||
      maxPrice != null ||
      condition != null ||
      (userLatitude != null && userLongitude != null);

  ProductFilters copyWith({
    String? query,
    String? category,
    TradeType? tradeType,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    ProductSortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    String? condition,
    bool clearCategory = false,
    bool clearTradeType = false,
    bool clearGeoFilter = false,
    bool clearCondition = false,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      tradeType: clearTradeType ? null : tradeType ?? this.tradeType,
      userLatitude: clearGeoFilter ? null : userLatitude ?? this.userLatitude,
      userLongitude: clearGeoFilter
          ? null
          : userLongitude ?? this.userLongitude,
      radiusInKm: radiusInKm ?? this.radiusInKm,
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: clearCondition ? null : condition ?? this.condition,
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

  void updateCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
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

  void setSortOption(ProductSortOption option) {
    state = state.copyWith(sortBy: option);
  }

  void updateSortBy(String? sortValue) {
    switch (sortValue) {
      case 'price_asc':
        state = state.copyWith(sortBy: ProductSortOption.priceAsc);
        break;
      case 'price_desc':
        state = state.copyWith(sortBy: ProductSortOption.priceDesc);
        break;
      case 'distance':
        state = state.copyWith(sortBy: ProductSortOption.distance);
        break;
      case 'recent':
      default:
        state = state.copyWith(sortBy: ProductSortOption.relevance);
        break;
    }
  }

  void setGeoFilter({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) {
    state = state.copyWith(
      userLatitude: latitude,
      userLongitude: longitude,
      radiusInKm: radiusInKm,
    );
  }

  void updateLocation(double? lat, double? lng) {
    if (lat == null || lng == null) {
      state = state.copyWith(clearGeoFilter: true);
    } else {
      state = state.copyWith(userLatitude: lat, userLongitude: lng);
    }
  }

  void updateMaxDistance(double distance) {
    state = state.copyWith(radiusInKm: distance);
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void updateCondition(String? condition) {
    if (condition == null) {
      state = state.copyWith(clearCondition: true);
    } else {
      state = state.copyWith(condition: condition);
    }
  }

  void clearGeoFilter() {
    state = state.copyWith(clearGeoFilter: true);
  }

  void clearFilters() {
    state = const ProductFilters();
  }

  void clear() => state = const ProductFilters();
}

final productFiltersProvider =
    NotifierProvider<ProductFiltersNotifier, ProductFilters>(
      ProductFiltersNotifier.new,
    );

final filteredProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final filters = ref.watch(productFiltersProvider);
  final repository = ref.watch(productRepositoryProvider);

  final items = await repository.getProducts(
    query: filters.query,
    category: filters.category,
    userLatitude: filters.userLatitude,
    userLongitude: filters.userLongitude,
    radiusInKm: filters.radiusInKm,
  );

  final processedList = items.where((product) {
    final matchesTradeType =
        filters.tradeType == null || product.tradeType == filters.tradeType;

    final matchesCondition =
        filters.condition == null || product.condition == filters.condition;

    if (product.price != null) {
      if (filters.minPrice != null && product.price! < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && product.price! > filters.maxPrice!) {
        return false;
      }
    }
    return matchesTradeType && matchesCondition;
  }).toList();

  switch (filters.sortBy) {
    case ProductSortOption.relevance:
      processedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case ProductSortOption.priceAsc:
      processedList.sort((a, b) {
        if (a.price == null && b.price == null) return 0;
        if (a.price == null) return 1;
        if (b.price == null) return -1;
        return a.price!.compareTo(b.price!);
      });
      break;
    case ProductSortOption.priceDesc:
      processedList.sort((a, b) {
        if (a.price == null && b.price == null) return 0;
        if (a.price == null) return 1;
        if (b.price == null) return -1;
        return b.price!.compareTo(a.price!);
      });
      break;
    case ProductSortOption.distance:
      break;
  }

  return processedList;
});
