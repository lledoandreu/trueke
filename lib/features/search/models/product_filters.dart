class ProductFilters {
  final String query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition; // e.g., 'nuevo', 'como_nuevo', 'bueno', 'aceptable'
  final String? sortBy; // e.g., 'recent', 'price_asc', 'price_desc', 'distance'
  final double maxDistanceKm;
  final double? userLat; // Coordenadas de referencia para proximidad
  final double? userLng;

  const ProductFilters({
    this.query = '',
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.sortBy = 'recent',
    this.maxDistanceKm = 50.0,
    this.userLat,
    this.userLng,
  });

  ProductFilters copyWith({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sortBy,
    double? maxDistanceKm,
    double? userLat,
    double? userLng,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      sortBy: sortBy ?? this.sortBy,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
    );
  }

  ProductFilters reset() {
    return const ProductFilters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilters &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          condition == other.condition &&
          sortBy == other.sortBy &&
          maxDistanceKm == other.maxDistanceKm &&
          userLat == other.userLat &&
          userLng == other.userLng;

  @override
  int get hashCode =>
      query.hashCode ^
      category.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      condition.hashCode ^
      sortBy.hashCode ^
      maxDistanceKm.hashCode ^
      userLat.hashCode ^
      userLng.hashCode;
}
