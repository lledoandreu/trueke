import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/settings/models/settings_model.dart';
import 'package:trueke/features/settings/presentation/providers/settings_providers.dart';
import 'package:trueke/features/settings/presentation/screens/settings_screen.dart';

// Mock exacto del notifier de ajustes
class MockSettingsNotifier extends SettingsNotifier {
  final SettingsModel _initialSettings;
  MockSettingsNotifier(this._initialSettings);

  @override
  Future<SettingsModel> build() async => _initialSettings;
}

void main() {
  testWidgets(
    'Renderiza las opciones de personalización y notificaciones push de forma correcta',
    (WidgetTester tester) async {
      const testSettings = SettingsModel(
        themeMode: 'system',
        pushNotificationsEnabled: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(
              () => MockSettingsNotifier(testSettings),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verificaciones básicas de la interfaz
      expect(find.text('Ajustes Globales'), findsOneWidget);
      expect(find.text('Personalización'), findsOneWidget);
      expect(find.text('Notificaciones Push'), findsOneWidget);
      expect(find.text('Recibe alertas de trueques y chats'), findsOneWidget);
    },
  );
}
