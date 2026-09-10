import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/models/search_product_mock.dart';
import 'package:trueke/features/search/providers/search_filters_provider.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';

class SearchResultsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    // En Riverpod manual, ref está disponible como propiedad de la clase base AsyncNotifier
    final filters = ref.watch(searchFiltersProvider);
    final repository = ref.watch(searchRepositoryProvider);

    final jsonList = await repository.searchProducts(filters);

    return jsonList.map((json) => Product.fromJson(json)).toList();
  }
}

final searchResultsProvider =
    AsyncNotifierProvider.autoDispose<SearchResultsNotifier, List<Product>>(
      SearchResultsNotifier.new,
    );
