import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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

  Future<String> uploadProductImage(XFile file) async {
    debugPrint('SUBIDA IMAGEN INICIO: ${file.name}');

    final repository = ref.read(productRepositoryProvider);

    final url = await repository.uploadProductImage(file);

    debugPrint('SUBIDA IMAGEN OK: $url');

    return url;
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);
