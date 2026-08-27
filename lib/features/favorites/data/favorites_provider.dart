import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  FavoritesNotifier() : super([]);

  // Método automático para añadir o quitar favoritos
  void toggleFavorite(Product product) {
    if (state.any((p) => p.id == product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  // Método automático para comprobar si un producto es favorito
  bool isFavorite(Product product) {
    return state.any((p) => p.id == product.id);
  }
}

// Proveedor global para usar en las pantallas
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
      return FavoritesNotifier();
    });
