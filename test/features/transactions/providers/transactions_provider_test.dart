import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/transactions/repositories/transactions_repository.dart';
import 'package:trueke/features/transactions/providers/transactions_provider.dart';

class MockTransactionsRepository implements TransactionsRepository {
  List<TradeTransaction> mockTransactions = [];
  String? lastUpdatedId;
  String? lastUpdatedStatus;
  TradeTransaction? lastCreatedTransaction;

  @override
  Future<List<TradeTransaction>> getUserTransactions(String userId) async {
    return mockTransactions;
  }

  @override
  Future<void> createTransaction(TradeTransaction transaction) async {
    lastCreatedTransaction = transaction;
  }

  @override
  Future<void> updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    lastUpdatedId = transactionId;
    lastUpdatedStatus = newStatus;
  }
}

void main() {
  group('UserTransactionsNotifier Tests', () {
    late ProviderContainer container;
    late MockTransactionsRepository mockRepository;
    const testUserId = 'user_123';

    setUp(() {
      mockRepository = MockTransactionsRepository();
      container = ProviderContainer(
        overrides: [
          transactionsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe cargar y emitir el historial de transacciones inicial correctamente',
      () async {
        final now = DateTime.now();
        mockRepository.mockTransactions = [
          TradeTransaction(
            id: 't_1',
            senderId: testUserId,
            receiverId: 'user_456',
            offeredProductId: 'p_offered',
            requestedProductId: 'p_requested',
            status: 'pending',
            createdAt: now,
          ),
        ];

        final transactions = await container.read(
          userTransactionsProvider(testUserId).future,
        );

        expect(transactions.length, equals(1));
        expect(transactions.first.id, equals('t_1'));
        expect(transactions.first.status, equals('pending'));
      },
    );

    test(
      'Debe invocar el repositorio al cambiar el estado de una propuesta',
      () async {
        mockRepository.mockTransactions = [];

        // Escuchamos el proveedor activamente
        container.listen<AsyncValue<List<TradeTransaction>>>(
          userTransactionsProvider(testUserId),
          (_, _) {},
        );

        final notifier = container.read(
          userTransactionsProvider(testUserId).notifier,
        );
        await notifier.changeStatus('t_1', 'accepted');

        expect(mockRepository.lastUpdatedId, equals('t_1'));
        expect(mockRepository.lastUpdatedStatus, equals('accepted'));
      },
    );
  });
}
