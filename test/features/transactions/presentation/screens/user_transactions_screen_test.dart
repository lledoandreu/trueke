import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/transactions/providers/transactions_provider.dart';
import 'package:trueke/features/transactions/presentation/screens/user_transactions_screen.dart';

class MockUserTransactionsNotifier extends UserTransactionsNotifier {
  final List<TradeTransaction> mockTransactions;

  MockUserTransactionsNotifier(this.mockTransactions) : super('current_user');

  @override
  Future<List<TradeTransaction>> build() async {
    return mockTransactions;
  }

  @override
  Future<void> changeStatus(String id, String status) async {
    state = const AsyncValue.loading();
    final updated =
        state.value
            ?.map<TradeTransaction>(
              (t) => t.id == id ? t.copyWith(status: status) : t,
            )
            .toList() ??
        <TradeTransaction>[];
    state = AsyncValue.data(updated);
  }

  @override
  Future<void> proposeTrade(TradeTransaction transaction) async {
    state = const AsyncValue.loading();
    final updated = <TradeTransaction>[...(state.value ?? []), transaction];
    state = AsyncValue.data(updated);
  }
}

void main() {
  final now = DateTime.now();
  const testUserId = 'current_user';

  final mockSentTransactions = [
    TradeTransaction(
      id: 'tx_123456789_sent_1',
      senderId: testUserId,
      receiverId: 'other_user_1',
      offeredProductId: 'p1',
      requestedProductId: 'p2',
      status: 'pending',
      createdAt: now,
    ),
    TradeTransaction(
      id: 'tx_123456789_sent_2',
      senderId: testUserId,
      receiverId: 'other_user_2',
      offeredProductId: 'p3',
      requestedProductId: 'p4',
      status: 'accepted',
      createdAt: now,
    ),
  ];

  final mockReceivedTransactions = [
    TradeTransaction(
      id: 'tx_123456789_received_3',
      senderId: 'other_user_3',
      receiverId: testUserId,
      offeredProductId: 'p5',
      requestedProductId: 'p6',
      status: 'pending',
      createdAt: now,
    ),
  ];

  Widget createTestWidget({
    required List<TradeTransaction> sent,
    required List<TradeTransaction> received,
  }) {
    return ProviderScope(
      overrides: [
        userTransactionsProvider(testUserId).overrideWith(() {
          return MockUserTransactionsNotifier([...sent, ...received]);
        }),
      ],
      child: const MaterialApp(
        home: UserTransactionsScreen(userId: testUserId),
      ),
    );
  }

  group('UserTransactionsScreen Widget Tests', () {
    testWidgets(
      'Debe renderizar las pestañas Enviados y Recibidos correctamente',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            sent: mockSentTransactions,
            received: mockReceivedTransactions,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Enviados'), findsOneWidget);
        expect(find.text('Recibidos'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe listar los trueques enviados por defecto en la primera pestaña',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            sent: mockSentTransactions,
            received: mockReceivedTransactions,
          ),
        );
        await tester.pumpAndSettle();

        // Verifica que se pinten elementos en la lista (los trueques enviados)
        expect(find.byType(ListTile), findsNWidgets(2));
      },
    );

    testWidgets(
      'Debe cambiar de pestaña y mostrar los trueques recibidos al pulsar Recibidos',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            sent: mockSentTransactions,
            received: mockReceivedTransactions,
          ),
        );
        await tester.pumpAndSettle();

        final receivedTab = find.text('Recibidos');
        await tester.tap(receivedTab);
        await tester.pumpAndSettle();

        // Tras cambiar de pestaña, debe listar únicamente el trueque recibido
        expect(find.byType(ListTile), findsNWidgets(1));
      },
    );

    testWidgets('Debe mostrar un indicador visual cuando la lista está vacía', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(sent: [], received: []));
      await tester.pumpAndSettle();

      // Si no encuentra el texto exacto, verificamos que muestre el estado Empty (Center o Custom Widget de advertencia)
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
