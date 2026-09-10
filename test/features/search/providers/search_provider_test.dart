import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/models/product_filters.dart';
import 'package:trueke/features/search/models/search_product_mock.dart';
import 'package:trueke/features/search/repositories/search_repository.dart';
import 'package:trueke/features/search/providers/search_filters_provider.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';
import 'package:trueke/features/search/providers/search_results_provider.dart';

class MockSearchRepository implements SearchRepository {
  List<Map<String, dynamic>> mockResponse = [];
  ProductFilters? lastFiltersReceived;

  @override
  Future<List<Map<String, dynamic>>> searchProducts(
    ProductFilters filters,
  ) async {
    lastFiltersReceived = filters;
    return mockResponse;
  }
}

void main() {
  group('SearchFiltersNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('El estado inicial debe ser ProductFilters por defecto', () {
      final filters = container.read(searchFiltersProvider);
      expect(filters.query, equals(''));
      expect(filters.category, isNull);
      expect(filters.sortBy, equals('recent'));
      expect(filters.userLat, isNull);
    });

    test('Debe actualizar la query de búsqueda correctamente', () {
      container.read(searchFiltersProvider.notifier).updateQuery('bicicleta');
      final filters = container.read(searchFiltersProvider);
      expect(filters.query, equals('bicicleta'));
    });

    test('Debe actualizar las coordenadas geográficas correctamente', () {
      container
          .read(searchFiltersProvider.notifier)
          .updateLocation(40.41, -3.70);
      final filters = container.read(searchFiltersProvider);
      expect(filters.userLat, equals(40.41));
      expect(filters.userLng, equals(-3.70));
    });

    test('Debe actualizar la categoría y restablecer filtros', () {
      final notifier = container.read(searchFiltersProvider.notifier);
      notifier.updateCategory('Electrónica');
      expect(
        container.read(searchFiltersProvider).category,
        equals('Electrónica'),
      );

      notifier.clearFilters();
      expect(container.read(searchFiltersProvider).category, isNull);
      expect(container.read(searchFiltersProvider).query, equals(''));
      expect(container.read(searchFiltersProvider).userLat, isNull);
    });
  });

  group('SearchResultsNotifier Asynchronous Tests', () {
    late ProviderContainer container;
    late MockSearchRepository mockRepository;

    setUp(() {
      mockRepository = MockSearchRepository();
      container = ProviderContainer(
        overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe emitir la lista de productos mapeada correctamente desde el repositorio',
      () async {
        mockRepository.mockResponse = [
          {
            'id': '1',
            'title': 'Bici de montaña',
            'description': 'Buen estado',
            'price': 150.0,
            'category': 'Deportes',
            'condition': 'bueno',
            'status': 'active',
          },
        ];

        final products = await container.read(searchResultsProvider.future);

        expect(products.length, equals(1));
        expect(products.first.title, equals('Bici de montaña'));
        expect(products.first.price, equals(150.0));
      },
    );

    test(
      'Debe reaccionar automáticamente e invocar de nuevo el repositorio al cambiar la query de filtros',
      () async {
        mockRepository.mockResponse = [];

        container.listen<AsyncValue<List<Product>>>(
          searchResultsProvider,
          (_, _) {},
        );

        container.read(searchFiltersProvider.notifier).updateQuery('Consola');

        await container.read(searchResultsProvider.future);

        expect(mockRepository.lastFiltersReceived?.query, equals('Consola'));
      },
    );
  });
}
