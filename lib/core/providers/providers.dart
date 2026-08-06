import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/products/repositories/local_product_repository.dart';
import '../../features/products/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const LocalProductRepository();
});
