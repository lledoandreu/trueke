import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/storage_service.dart';
import 'package:trueke/models/product.dart';

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  () {
    return ProductsNotifier();
  },
);

final myProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final myId = Supabase.instance.client.auth.currentUser?.id;
  return productsAsync.whenData(
    (list) => list.where((p) => p.ownerId == myId).toList(),
  );
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Product>> build() async {
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('products').insert(product.toJson());
      final updated = await _fetchProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
      final updated = await _fetchProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProductImage(XFile image) async {
    try {
      return await StorageService().uploadProductImage(File(image.path));
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from("products").delete().eq("id", id);
      final updated = await _fetchProducts();
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProductImage(String url) async {
    await StorageService().deleteProductImage(url);
  }
}
