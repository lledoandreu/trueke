import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trueke/app/router/app_router.dart';
import 'package:trueke/app/routes/app_routes.dart';

void main() {
  Future<void> pumpRoute(WidgetTester tester, RouteSettings settings) async {
    final route = AppRouter.onGenerateRoute(settings);

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(initialRoute: '/', onGenerateRoute: (_) => route),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra 404 para un producto sin argumentos', (tester) async {
    await pumpRoute(tester, const RouteSettings(name: AppRoutes.product));

    expect(find.text('Página no encontrada'), findsOneWidget);
    expect(find.text('404'), findsOneWidget);
  });

  testWidgets('muestra 404 para una oferta sin producto válido', (
    tester,
  ) async {
    await pumpRoute(
      tester,
      const RouteSettings(
        name: AppRoutes.sendTradeOffer,
        arguments: 'argumento-inválido',
      ),
    );

    expect(find.text('Página no encontrada'), findsOneWidget);
  });

  testWidgets('muestra 404 para una ruta desconocida', (tester) async {
    await pumpRoute(tester, const RouteSettings(name: '/ruta-inexistente'));

    expect(find.text('Página no encontrada'), findsOneWidget);
  });
}
