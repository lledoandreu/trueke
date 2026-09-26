import 'package:image_picker/image_picker.dart';
import '../../../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
  });

  Future<Product?> getProductById(String id);

  Future<void> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<String> uploadProductImage(XFile file);

  Future<void> deleteProductImage(String publicUrl);
}
