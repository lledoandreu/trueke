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
    return ref.watch(productRepositoryProvider).getProducts();
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
