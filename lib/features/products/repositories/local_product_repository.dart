import '../../../data/sample_products.dart';
import '../../../models/product.dart';

import 'product_repository.dart';

class LocalProductRepository implements ProductRepository {
  const LocalProductRepository();

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return sampleProducts;
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return sampleProducts.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    sampleProducts.add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = sampleProducts.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      sampleProducts[index] = product;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    sampleProducts.removeWhere((product) => product.id == id);
  }
}
