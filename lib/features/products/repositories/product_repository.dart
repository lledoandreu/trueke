import '../../../data/sample_products.dart';
import '../../../models/product.dart';

class ProductRepository {
  const ProductRepository();

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return sampleProducts;
  }
}
