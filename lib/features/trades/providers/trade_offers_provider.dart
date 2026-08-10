import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/trade_offer.dart';

class TradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  static const _offersKey = 'trade_offers';

  @override
  Future<List<TradeOffer>> build() async {
    final preferences = await SharedPreferences.getInstance();
    final savedOffers = preferences.getString(_offersKey);

    if (savedOffers == null) {
      return [];
    }

    return (jsonDecode(savedOffers) as List<dynamic>)
        .map(
          (item) => TradeOffer.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> sendOffer({
    required String productId,
    required String productTitle,
    required String message,
  }) async {
    final List<TradeOffer> updatedOffers = [
      TradeOffer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        productId: productId,
        productTitle: productTitle,
        message: message,
        createdAt: DateTime.now(),
      ),
      ...(state.valueOrNull ?? <TradeOffer>[]),
    ];

    state = AsyncData<List<TradeOffer>>(updatedOffers);

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _offersKey,
      jsonEncode(
        updatedOffers
            .map((offer) => offer.toJson())
            .toList(),
      ),
    );
  }
}

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(
  TradeOffersNotifier.new,
);
