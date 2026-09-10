import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/favorites_provider.dart';
import 'package:trueke/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:trueke/models/product.dart';

// Heredamos directamente de FavoritesNotifier para cumplir con el tipo estático estricto
class MockFavoritesNotifier extends FavoritesNotifier {
  final List<Product> _mockData;
  MockFavoritesNotifier(this._mockData);

  @override
  Future<List<Product>> build() async => _mockData;
}

void main() {
  testWidgets('Muestra mensaje de lista vacía cuando no hay favoritos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith(() => MockFavoritesNotifier([])),
        ],
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('Aún no tienes productos favoritos'), findsOneWidget);
  });
}
