import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/search_page.dart';

void main() {
  group('Pruebas de Widget - Filtros de Geolocalizacion en SearchPage', () {
    testWidgets(
      'Debe renderizar el FilterChip de geolocalizacion Cerca de mi',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: SearchPage())),
        );

        await tester.pumpAndSettle();

        final geoChipFinder = find.byKey(const Key('geo_filter_chip'));
        expect(geoChipFinder, findsOneWidget);
        expect(find.text('Cerca de mí'), findsOneWidget);
      },
    );
  });
}
