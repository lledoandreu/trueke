import 'package:flutter_test/flutter_test.dart';

import 'package:trueke/models/trade_offer.dart';

void main() {
  group('TradeOffer', () {
    test('parses a pending incoming offer', () {
      final offer = TradeOffer.fromJson({
        'id': 'offer-1',
        'product_id': 'product-1',
        'product_title': 'Cámara',
        'message': 'Te ofrezco un objetivo',
        'created_at': '2026-09-02T10:00:00.000Z',
        'status': 'sent',
        'from_user_id': 'user-a',
        'to_user_id': 'user-b',
        'offered_product_id': 'product-2',
        'offered_product_title': 'Objetivo',
      }, currentUserId: 'user-b');

      expect(offer.isPending, isTrue);
      expect(offer.isIncoming, isTrue);
      expect(offer.status, TradeOfferStatus.sent);
      expect(offer.offeredProductId, 'product-2');
    });

    test('copyWith only updates status', () {
      final offer = TradeOffer(
        id: 'offer-1',
        productId: 'product-1',
        productTitle: 'Cámara',
        message: 'Hola',
        createdAt: DateTime.utc(2026, 9, 2),
        fromUserId: 'user-a',
        toUserId: 'user-b',
        isIncoming: true,
      );

      final accepted = offer.copyWith(status: TradeOfferStatus.accepted);

      expect(accepted.status, TradeOfferStatus.accepted);
      expect(accepted.isPending, isFalse);
      expect(accepted.productId, offer.productId);
      expect(accepted.message, offer.message);
    });
  });
}
