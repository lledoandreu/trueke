import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/trade_offer.dart';
import '../repositories/trade_repository.dart';

final tradeRepositoryProvider = Provider<BaseTradeRepository>((ref) {
  return SupabaseTradeRepository();
});

// Escucha automática de ofertas entrantes en segundo plano
final incomingOffersProvider = FutureProvider<List<TradeOffer>>((ref) async {
  final repository = ref.watch(tradeRepositoryProvider);
  return repository.fetchIncomingOffers();
});

// Escucha automática de ofertas enviadas en segundo plano
final outgoingOffersProvider = FutureProvider<List<TradeOffer>>((ref) async {
  final repository = ref.watch(tradeRepositoryProvider);
  return repository.fetchOutgoingOffers();
});
