import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/support/presentation/providers/support_providers.dart';
import 'package:trueke/features/support/presentation/screens/create_report_screen.dart';

// Mock simple para emular las mutaciones de soporte
class MockSupportMutationNotifier extends SupportMutationNotifier {
  @override
  Future<void> build() async {}
}

void main() {
  testWidgets(
    'Renderiza correctamente el formulario de reportes con sus opciones',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supportMutationProvider.overrideWith(
              () => MockSupportMutationNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: CreateReportScreen(
              targetId: 'prod_123',
              targetType: 'product',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificaciones de UI básicas
      expect(find.text('Enviar Reporte'), findsAtLeastNWidgets(1));
      expect(find.text('¿Cuál es el motivo de este reporte?'), findsOneWidget);
      expect(find.text('Contenido inapropiado'), findsOneWidget);
    },
  );
}
