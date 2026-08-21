import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository();

  final SupabaseClient _client = Supabase.instance.client;

  static const _table = 'products';

  @override
  Future<List<Product>> getProducts() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
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
  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

  await Supabase.instance.client.storage
      .from('product-images')
      .upload(
        fileName,
        File(file.path),
      );

  return Supabase.instance.client.storage
      .from('product-images')
      .getPublicUrl(fileName);
}

}
