import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product.dart';
import '../../../models/trade_offer.dart';
import '../../auth/auth_service.dart';
import '../repositories/trade_offer_repository.dart';

final tradeOfferRepositoryProvider = Provider<TradeOfferRepository>((ref) {
  return TradeOfferRepository();
});

class TradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  TradeOfferRepository get _repository =>
      ref.read(tradeOfferRepositoryProvider);

  @override
  Future<List<TradeOffer>> build() async {
    final userId = ref.watch(authUserIdProvider).valueOrNull;

    if (userId == null) {
      return [];
    }

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

  Future<void> refreshOffers() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_repository.getOffers);
  }
}

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(
      TradeOffersNotifier.new,
    );
