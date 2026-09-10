import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/services/notifications/providers/notifications_history_provider.dart';
import 'package:trueke/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:trueke/features/transactions/models/notification_model.dart';

// Mock exacto heredando de la clase base del AsyncNotifier original
class MockNotificationsHistoryNotifier extends NotificationsHistoryNotifier {
  final List<NotificationModel> _mockData;
  MockNotificationsHistoryNotifier(this._mockData);

  @override
  Future<List<NotificationModel>> build() async => _mockData;
}

void main() {
  testWidgets(
    'Muestra vista vacía amigable cuando no existen notificaciones en la bandeja',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsHistoryProvider.overrideWith(
              () => MockNotificationsHistoryNotifier([]),
            ),
          ],
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      expect(find.text('Tu bandeja de entrada está vacía'), findsOneWidget);
    },
  );
}
