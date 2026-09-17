import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';
import 'package:trueke/features/products/providers/products_provider.dart';

// Heredamos directamente de ProductsNotifier para corregir el conflicto de tipos
class MockProductsNotifier extends ProductsNotifier {
  final List<Product> _testProducts;
  MockProductsNotifier(this._testProducts);

  @override
  Future<List<Product>> build() async => _testProducts;
}

void main() {
  final productA = Product(
    id: 'a',
    title: 'Producto Barato Cercano',
    description: 'Test A',
    price: 10.0,
    tradeType: TradeType.sale,
    category: 'Electrónica',
    location: 'Madrid',
    owner: 'User A',
    condition: 'Nueva',
    wanted: 'Nada',
    createdAt: DateTime(2026, 1, 1),
    latitude: 40.4167,
    longitude: -3.7037,
    images: const ['img_a'],
  );

  final productB = Product(
    id: 'b',
    title: 'Producto Caro Intermedio',
    description: 'Test B',
    price: 100.0,
    tradeType: TradeType.sale,
    category: 'Moda',
    location: 'Alcorcón',
    owner: 'User B',
    condition: 'Usado',
    wanted: 'Nada',
    createdAt: DateTime(2026, 1, 2),
    latitude: 40.3456,
    longitude: -3.8248,
    images: const ['img_b'],
  );

  final productC = Product(
    id: 'c',
    title: 'Producto Gratis Lejano',
    description: 'Test C',
    price: null,
    tradeType: TradeType.trade,
    category: 'Electrónica',
    location: 'Barcelona',
    owner: 'User C',
    condition: 'Nueva',
    wanted: 'Algo',
    createdAt: DateTime(2026, 1, 3),
    latitude: 41.3851,
    longitude: 2.1734,
    images: const ['img_c'],
  );

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        productsProvider.overrideWith(
          () => MockProductsNotifier([productA, productB, productC]),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Ordenación por Relevancia (Cronológica descendente)', () async {
    await container.read(productsProvider.future);

    container
        .read(productFiltersProvider.notifier)
        .setSortOption(ProductSortOption.relevance);
    final filteredState = container.read(filteredProductsProvider);

    filteredState.whenData((list) {
      expect(list.length, 3);
      expect(list[0].id, 'c');
      expect(list[1].id, 'b');
      expect(list[2].id, 'a');
    });
  });

  test('Ordenación por Precio Ascendente (Nulos al final)', () async {
    await container.read(productsProvider.future);

    container
        .read(productFiltersProvider.notifier)
        .setSortOption(ProductSortOption.priceAsc);
    final filteredState = container.read(filteredProductsProvider);

    filteredState.whenData((list) {
      expect(list.length, 3);
      expect(list[0].id, 'a');
      expect(list[1].id, 'b');
      expect(list[2].id, 'c');
    });
  });

  test('Ordenación por Precio Descendente (Nulos al final)', () async {
    await container.read(productsProvider.future);

    container
        .read(productFiltersProvider.notifier)
        .setSortOption(ProductSortOption.priceDesc);
    final filteredState = container.read(filteredProductsProvider);

    filteredState.whenData((list) {
      expect(list.length, 3);
      expect(list[0].id, 'b');
      expect(list[1].id, 'a');
      expect(list[2].id, 'c');
    });
  });

  test('Ordenación por Proximidad Geográfica (GPS desde Madrid)', () async {
    await container.read(productsProvider.future);

    container
        .read(productFiltersProvider.notifier)
        .setGeoFilter(
          latitude: 40.4167,
          longitude: -3.7037,
          radiusInKm: 1000.0,
        );

    container
        .read(productFiltersProvider.notifier)
        .setSortOption(ProductSortOption.distance);
    final filteredState = container.read(filteredProductsProvider);

    filteredState.whenData((list) {
      expect(list.length, 3);
      expect(list[0].id, 'a');
      expect(list[1].id, 'b');
      expect(list[2].id, 'c');
    });
  });
}
