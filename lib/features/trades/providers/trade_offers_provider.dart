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
  }) async {
    await _repository.sendOffer(product: product, message: message);

    state = AsyncData(await _repository.getOffers());
  }
}

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(
      TradeOffersNotifier.new,
    );
