import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trueke/app/app.dart';

void main() {
  testWidgets('Trueke inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TruekeApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TruekeApp), findsOneWidget);
  });
}
