import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../models/product.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repository = ref.watch(productRepositoryProvider);

    return repository.getProducts();
  }

  Future<void> addProduct(Product product) async {
    final repository = ref.read(productRepositoryProvider);

    await repository.createProduct(product);

    state = AsyncData(await repository.getProducts());
  }

  Future<void> updateProduct(Product product) async {
    final repository = ref.read(productRepositoryProvider);

    await repository.updateProduct(product);

    state = AsyncData(await repository.getProducts());
  }

  Future<void> deleteProduct(String id) async {
    final repository = ref.read(productRepositoryProvider);

    await repository.deleteProduct(id);

    state = AsyncData(await repository.getProducts());
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);
