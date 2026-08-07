import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/products/providers/products_provider.dart';
import '../../models/product.dart';

class FavoritesNotifier extends AsyncNotifier<List<Product>> {
  static const String _favoritesKey = 'favorite_product_ids';

  @override
  Future<List<Product>> build() async {
    final preferences = await SharedPreferences.getInstance();

    final favoriteIds =
        preferences.getStringList(_favoritesKey) ?? [];

    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        return products
            .where((product) => favoriteIds.contains(product.id))
            .toList();
      },
      loading: () => [],
      error: (_, _) => [],
    );
  }

  bool isFavorite(Product product) {
    return state.valueOrNull?.any(
          (item) => item.id == product.id,
        ) ??
        false;
  }

  Future<void> toggleFavorite(Product product) async {
    final currentFavorites = state.valueOrNull ?? [];

    final isCurrentlyFavorite = currentFavorites.any(
      (item) => item.id == product.id,
    );

    final updatedFavorites = isCurrentlyFavorite
        ? currentFavorites
            .where((item) => item.id != product.id)
            .toList()
        : [
            ...currentFavorites,
            product,
          ];

    state = AsyncData(updatedFavorites);

    final preferences = await SharedPreferences.getInstance();

    final ids = updatedFavorites
        .map((product) => product.id)
        .toList();

    await preferences.setStringList(
      _favoritesKey,
      ids,
    );
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Product>>(
  FavoritesNotifier.new,
);
