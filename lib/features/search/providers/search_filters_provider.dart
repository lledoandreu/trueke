import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/models/product_filters.dart';

class SearchFiltersNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() {
    return const ProductFilters();
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateCondition(String? condition) {
    state = state.copyWith(condition: condition);
  }

  void updateSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updateMaxDistance(double distance) {
    state = state.copyWith(maxDistanceKm: distance);
  }

  void updateLocation(double? lat, double? lng) {
    state = state.copyWith(userLat: lat, userLng: lng);
  }

  void clearFilters() {
    state = state.reset();
  }
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, ProductFilters>(
      SearchFiltersNotifier.new,
    );
