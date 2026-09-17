import 'package:trueke/core/supabase/supabase_client.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'product_repository_provider.dart';
import 'package:trueke/models/product.dart';

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  () {
    return ProductsNotifier();
  },
);

final myProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  return productsAsync.whenData(
    (list) => list.where((p) => p.ownerId == myId).toList(),
  );
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final remoteProducts = await ref
        .watch(productRepositoryProvider)
        .getProducts();

    if (remoteProducts.isNotEmpty) {
      return remoteProducts;
    }

    return [
      Product(
        id: 'mock-1',
        title: 'iPhone 13 Pro 128GB',
        description:
            'Impecable estado, salud de bateria 87%. Busco cambio por Portatil o iPad Pro.',
        price: 550.0,
        images: ['https://unsplash.com'],
        tradeType: TradeType.trade,
        category: 'Electronica',
        location: 'Madrid',
        owner: 'Carlos G.',
        ownerId: 'mock-owner-1',
        condition: 'Buen estado',
        wanted: 'Portatil o iPad Pro',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'mock-2',
        title: 'Chaqueta de Cuero Vintage',
        description:
            'Talla L, cuero autentico pesado estilo motero. Intercambio por abrigo similar talla M.',
        price: 85.0,
        images: ['https://unsplash.com'],
        tradeType: TradeType.trade,
        category: 'Moda',
        location: 'Barcelona',
        owner: 'Elena R.',
        ownerId: 'mock-owner-2',
        condition: 'Como nuevo',
        wanted: 'Abrigo talla M',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'mock-3',
        title: 'Cafetera Express DeLonghi',
        description:
            'Muy poco uso, con todos los accesorios. Busco trueke por herramientas de bricolaje.',
        price: 120.0,
        images: ['https://unsplash.com'],
        tradeType: TradeType.tradeAndMoney,
        category: 'Hogar',
        location: 'Valencia',
        owner: 'Javier M.',
        ownerId: 'mock-owner-3',
        condition: 'Usado',
        wanted: 'Herramientas de bricolaje',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'mock-4',
        title: 'Mando PS5 DualSense Edge',
        description:
            'Mando pro personalizable, caja y joysticks de repuesto. Cambio por juegos de Nintendo Switch.',
        price: 160.0,
        images: ['https://unsplash.com'],
        tradeType: TradeType.trade,
        category: 'Gaming',
        location: 'Sevilla',
        owner: 'Sergio T.',
        ownerId: 'mock-owner-4',
        condition: 'Buen estado',
        wanted: 'Juegos Nintendo Switch',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'mock-5',
        title: 'Bicicleta de Montaña Rockrider',
        description:
            'Ruedas de 29 pulgadas, frenos hidraulicos, suspension delantera. Busco patinete electrico.',
        price: 320.0,
        images: ['https://unsplash.com'],
        tradeType: TradeType.trade,
        category: 'Deporte',
        location: 'Zaragoza',
        owner: 'Andres P.',
        ownerId: 'mock-owner-5',
        condition: 'Usado',
        wanted: 'Patinete electrico',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.createProduct(product);
      final updated = await repo.getProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(product);
      final updated = await repo.getProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProductImage(XFile image) async {
    try {
      return await ref
          .read(productRepositoryProvider)
          .uploadProductImage(image);
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> deleteProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(productRepositoryProvider);

      if (product.imageUrl.isNotEmpty) {
        try {
          await repo.deleteProductImage(product.imageUrl);
        } catch (_) {
          // Captura silenciosa para evitar romper el flujo si el archivo no existe
        }
      }

      await repo.deleteProduct(product.id);
      final updated = await repo.getProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProductImage(String url) async {
    await ref.read(productRepositoryProvider).deleteProductImage(url);
  }
}
