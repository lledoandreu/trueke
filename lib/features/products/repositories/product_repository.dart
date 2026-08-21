import '../../../models/product.dart';

import 'package:image_picker/image_picker.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<Product?> getProductById(String id);

  Future<void> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<String> uploadProductImage(XFile file);
}
