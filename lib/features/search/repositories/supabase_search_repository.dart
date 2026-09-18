import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';
import 'package:trueke/features/search/repositories/search_repository.dart';

class SupabaseSearchRepository implements SearchRepository {
  final SupabaseClient _supabaseClient;

  const SupabaseSearchRepository(this._supabaseClient);

  @override
  Future<List<Map<String, dynamic>>> searchProducts(
    ProductFilters filters,
  ) async {
    if (filters.userLatitude != null && filters.userLongitude != null) {
      final response = await _supabaseClient.rpc(
        'search_products_by_distance',
        params: {
          'user_latitude': filters.userLatitude!,
          'user_longitude': filters.userLongitude!,
          'max_distance_km': filters.radiusInKm,
          'search_query': filters.query.trim().isEmpty
              ? null
              : filters.query.trim(),
          'filter_category': filters.category,
          'min_price': filters.minPrice,
          'max_price': filters.maxPrice,
          'filter_condition': filters.condition,
          'sort_by': filters.sortBy.name,
        },
      );
      return List<Map<String, dynamic>>.from(response as List);
    }

    var query = _supabaseClient
        .from('products')
        .select()
        .eq('status', 'active');

    if (filters.query.trim().isNotEmpty) {
      query = query.ilike('title', '%${filters.query.trim()}%');
    }

    if (filters.category != null && filters.category!.isNotEmpty) {
      query = query.eq('category', filters.category!);
    }

    if (filters.minPrice != null) {
      query = query.gte('price', filters.minPrice!);
    }

    if (filters.maxPrice != null) {
      query = query.lte('price', filters.maxPrice!);
    }

    if (filters.condition != null && filters.condition!.isNotEmpty) {
      query = query.eq('condition', filters.condition!);
    }

    PostgrestTransformBuilder<PostgrestList> finalQuery;

    switch (filters.sortBy) {
      case ProductSortOption.priceAsc:
        finalQuery = query.order('price', ascending: true);
        break;
      case ProductSortOption.priceDesc:
        finalQuery = query.order('price', ascending: false);
        break;
      case ProductSortOption.relevance:
      default:
        finalQuery = query.order('created_at', ascending: false);
        break;
    }

    final response = await finalQuery;
    return List<Map<String, dynamic>>.from(response);
  }
}
