import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/presentation/widgets/add_review_dialog.dart';

void main() {
  const targetReceiverId = 'receiver_789';

  testWidgets(
    'Debe renderizar los elementos básicos del diálogo de valoración',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AddReviewDialog(receiverId: targetReceiverId)),
          ),
        ),
      );

      expect(find.text('Valorar usuario'), findsOneWidget);
      expect(
        find.text('¿Cómo calificarías tu experiencia en este trueque?'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Enviar'), findsOneWidget);
    },
  );

  testWidgets(
    'Debe permitir interactuar con las estrellas para cambiar la puntuación',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AddReviewDialog(receiverId: targetReceiverId)),
          ),
        ),
      );

      // Buscamos los botones de las estrellas
      final starButtons = find.byType(IconButton);
      expect(starButtons, findsNWidgets(5));

      // Simulamos pulsar la tercera estrella
      await tester.tap(starButtons.at(2));
      await tester.pump();

      // El estado del widget cambia internamente sin romper el flujo del árbol
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(3));
    },
  );
}
