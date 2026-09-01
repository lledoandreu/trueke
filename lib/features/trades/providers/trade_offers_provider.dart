import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/trade_offer.dart';

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(() {
      return TradeOffersNotifier();
    });

class TradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TradeOffer>> build() async {
    return _fetchOffers();
  }

  Future<List<TradeOffer>> _fetchOffers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('trade_offers')
          .select()
          .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map(
            (json) => TradeOffer.fromJson(
              json as Map<String, dynamic>,
              currentUserId: userId,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> sendOffer({
    required String productId,
    required String productTitle,
    required String message,
    required String toUserId,
    String? offeredProductId,
    String? offeredProductTitle,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase.from('trade_offers').insert({
        'product_id': productId,
        'product_title': productTitle,
        'message': message,
        'from_user_id': userId,
        'to_user_id': toUserId,
        'status': TradeOfferStatus.sent.name,
        'offered_product_id': offeredProductId,
        'offered_product_title': offeredProductTitle,
        'created_at': DateTime.now().toIso8601String(),
      });

      final updatedOffers = await _fetchOffers();
      state = AsyncValue.data(updatedOffers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> respondToOffer({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabase
          .from('trade_offers')
          .update({'status': status.name})
          .eq('id', offer.id);

      final updatedOffers = await _fetchOffers();
      state = AsyncValue.data(updatedOffers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
