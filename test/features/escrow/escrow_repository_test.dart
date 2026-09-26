import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueke/features/escrow/models/escrow_transaction.dart';
import 'package:trueke/features/escrow/repositories/escrow_repository.dart';

class MockEscrowRepository extends Mock implements EscrowRepository {}

void main() {
  late MockEscrowRepository mockRepository;

  setUp(() {
    mockRepository = MockEscrowRepository();
  });

  group('EscrowRepository Tests', () {
    const mockTransaction = EscrowTransaction(
      id: 'escrow-123',
      tradeOfferId: 'offer-456',
      buyerId: 'user-buyer',
      sellerId: 'user-seller',
      amount: 50.0,
      currency: 'EUR',
      status: EscrowStatus.pendingDeposit,
      stripePaymentIntentId: 'pi_test123',
    );

    test(
      'getEscrowByTradeOfferId devuelve un EscrowTransaction valido',
      () async {
        when(
          () => mockRepository.getEscrowByTradeOfferId('offer-456'),
        ).thenAnswer((_) async => mockTransaction);

        final result = await mockRepository.getEscrowByTradeOfferId(
          'offer-456',
        );

        expect(result.id, 'escrow-123');
        expect(result.status, EscrowStatus.pendingDeposit);
        expect(result.amount, 50.0);
      },
    );
  });
}
