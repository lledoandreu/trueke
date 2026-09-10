import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/profile/presentation/screens/profile_screen.dart';

void main() {
  const userId = 'user-123';
  final testProfile = UserProfile(
    id: userId,
    email: 'test@trueke.com',
    displayName: 'Test User',
    bio: 'My bio',
    avatarUrl: '',
    averageRating: 4.5,
    totalRatings: 10,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  testWidgets('Debe mostrar indicador de carga inicialmente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider(userId).overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return testProfile;
          }),
        ],
        child: const MaterialApp(home: ProfileScreen(userId: userId)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Debe renderizar los datos del perfil correctamente cuando la carga es exitosa',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider(
              userId,
            ).overrideWith((ref) async => testProfile),
          ],
          child: const MaterialApp(home: ProfileScreen(userId: userId)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('test@trueke.com'), findsOneWidget);
      expect(find.text('4.5 (10 valoraciones)'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Nombre de usuario'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Biografía'), findsOneWidget);
    },
  );
}
