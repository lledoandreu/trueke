import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/models/product_filters.dart';
import 'package:trueke/features/search/repositories/search_repository.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';
import 'package:trueke/features/search/presentation/screens/search_screen.dart';
import 'package:trueke/features/search/presentation/widgets/search_filters_widget.dart';

class MockSearchWidgetRepository implements SearchRepository {
  List<Map<String, dynamic>> mockResponse = [];

  @override
  Future<List<Map<String, dynamic>>> searchProducts(
    ProductFilters filters,
  ) async {
    return mockResponse;
  }
}

void main() {
  late MockSearchWidgetRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchWidgetRepository();
  });

  Widget createSearchScreenTestWidget() {
    return ProviderScope(
      overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: SearchScreen()),
    );
  }

  testWidgets(
    'Debe renderizar la SearchScreen con el campo de texto y el boton de filtros',
    (WidgetTester tester) async {
      mockRepository.mockResponse = [];

      await tester.pumpWidget(createSearchScreenTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    },
  );

  testWidgets(
    'Debe mostrar un mensaje de lista vacia cuando no hay productos que coincidan',
    (WidgetTester tester) async {
      mockRepository.mockResponse = [];

      await tester.pumpWidget(createSearchScreenTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('No encontramos productos con esos filtros'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Debe desplegar el modal de filtros y reaccionar al Switch de ubicacion',
    (WidgetTester tester) async {
      mockRepository.mockResponse = [];

      await tester.pumpWidget(createSearchScreenTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(SearchFiltersWidget), findsOneWidget);
      expect(find.text('Usar mi ubicación actual'), findsOneWidget);

      // Verificamos que el Slider de km NO se muestra inicialmente porque las coordenadas de referencia son nulas
      expect(find.byType(Slider), findsNothing);

      // Activamos el Switch de geolocalización simulada
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Verificamos que ahora el Slider de distancia máxima aparece de manera reactiva
      expect(find.byType(Slider), findsOneWidget);
    },
  );
}
