import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProducts();
});
