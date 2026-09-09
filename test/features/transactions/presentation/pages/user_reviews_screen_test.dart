import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/presentation/pages/user_reviews_screen.dart';

void main() {
  const targetUserId = 'user_999';
  const targetUserName = 'Carlos';

  testWidgets(
    'Debe renderizar el AppBar con el nombre del usuario y el boton de valorar',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UserReviewsScreen(
              userId: targetUserId,
              userName: targetUserName,
            ),
          ),
        ),
      );

      // Verificamos que el título del AppBar incluya el nombre del usuario pasado por parámetro
      expect(find.text('Valoraciones de Carlos'), findsOneWidget);

      // Verificamos el texto de la sección general
      expect(find.text('Opiniones de la comunidad'), findsOneWidget);

      // Verificamos la existencia del FloatingActionButton extendido mediante su etiqueta
      expect(find.text('Valorar'), findsOneWidget);
    },
  );
}
