import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client)
    : _storageService = StorageService(_client);

  final SupabaseClient _client;
  final StorageService _storageService;

  static const _table = 'products';

  @override
  Future<List<Product>> getProducts({
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
  }) async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    final allProducts = (response as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    if (userLatitude == null || userLongitude == null || radiusInKm == null) {
      return allProducts;
    }

    return allProducts.where((product) {
      if (product.latitude == null || product.longitude == null) {
        return false;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        product.latitude!,
        product.longitude!,
      );

      final distanceInKm = distanceInMeters / 1000.0;
      return distanceInKm <= radiusInKm;
    }).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Product.fromJson(response);
  }

  @override
  Future<void> createProduct(Product product) async {
    await _client.from(_table).insert(product.toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _client.from(_table).update(product.toJson()).eq('id', product.id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<String> uploadProductImage(XFile file) async {
    return _storageService.uploadProductImage(File(file.path));
  }

  @override
  Future<void> deleteProductImage(String publicUrl) async {
    await _storageService.deleteProductImage(publicUrl);
  }
}
