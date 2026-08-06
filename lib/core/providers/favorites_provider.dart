import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';

class FavoritesNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return [];
  }

  bool isFavorite(Product product) {
    return state.any(
      (item) => item.id == product.id,
    );
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      state = state
          .where(
            (item) => item.id != product.id,
          )
          .toList();
    } else {
      state = [
        ...state,
        product,
      ];
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Product>>(
  FavoritesNotifier.new,
);
