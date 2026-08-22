import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trueke/app/app.dart';
import 'package:trueke/core/supabase/supabase_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  });

  testWidgets('Trueke muestra el acceso sin una sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TruekeApp()));

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });
}
