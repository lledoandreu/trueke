import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/sample_products.dart';
import '../../../models/product.dart';

import 'product_repository.dart';

class LocalProductRepository implements ProductRepository {
  const LocalProductRepository();

  static const _productsKey = 'products';

  @override
  Future<List<Product>> getProducts() async {
    final preferences = await SharedPreferences.getInstance();
    final savedProducts = preferences.getString(_productsKey);
    if (savedProducts == null) {
      await _saveProducts(sampleProducts);
      return List.of(sampleProducts);
    }

    return (jsonDecode(savedProducts) as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return (await getProducts()).firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    final products = await getProducts();
    await _saveProducts([...products, product]);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      products[index] = product;
      await _saveProducts(products);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((product) => product.id == id);
    await _saveProducts(products);
  }

  Future<void> _saveProducts(List<Product> products) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _productsKey,
      jsonEncode(products.map((product) => product.toJson()).toList()),
    );
  }

  @override
  Future<String> uploadProductImage(String filePath) async {
    throw UnimplementedError('Local repository does not support image upload');
  }

}
