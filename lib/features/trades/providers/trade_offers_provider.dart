import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../models/trade_offer.dart';
import '../repositories/trade_offer_repository.dart';

class TradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  TradeOfferRepository get _repository => TradeOfferRepository();

  @override
  Future<List<TradeOffer>> build() {
    return _repository.getOffers();
  }

  Future<void> sendOffer({
    required Product product,
    required String message,
    Product? offeredProduct,
  }) async {
    await _repository.sendOffer(
      product: product,
      message: message,
      offeredProduct: offeredProduct,
    );

    state = AsyncData(await _repository.getOffers());
  }

  Future<void> respondToOffer({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    await _repository.updateStatus(offer: offer, status: status);

    state = AsyncData(await _repository.getOffers());
  }
}

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(
      TradeOffersNotifier.new,
    );
