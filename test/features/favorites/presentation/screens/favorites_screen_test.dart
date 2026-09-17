import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/favorites/favorites_page.dart';

void main() {
  testWidgets('FavoritesPage renderiza correctamente con estructura Riverpod', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FavoritesPage())),
    );

    expect(find.byType(FavoritesPage), findsOneWidget);
  });
}
