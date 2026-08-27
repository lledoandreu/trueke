import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import 'product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Proveedor automático que descarga los productos en segundo plano
final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});
