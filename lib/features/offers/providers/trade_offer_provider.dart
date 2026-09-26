import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/trade_offer.dart';
import '../repositories/trade_offer_repository.dart';

/// Proveedor clásico del Repositorio de Ofertas
final tradeOfferRepositoryProvider = Provider<TradeOfferRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TradeOfferRepository(client);
});

/// Notificador de Estado Tradicional utilizando StreamNotifier (Sin Macros)
class UserTradeOffersNotifier extends StreamNotifier<List<TradeOffer>> {
  final StreamController<List<TradeOffer>> _controller =
      StreamController<List<TradeOffer>>();

  @override
  Stream<List<TradeOffer>> build() {
    _loadOffers();
    ref.onDispose(() {
      _controller.close();
    });
    return _controller.stream;
  }

  Future<void> _loadOffers() async {
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    if (currentUser == null) {
      _controller.add([]);
      return;
    }
    try {
      final repo = ref.read(tradeOfferRepositoryProvider);
      final offers = await repo.fetchOffersByUserId(currentUser.id);
      _controller.add(offers);
    } catch (e, st) {
      _controller.addError(e, st);
    }
  }

  /// Propone una nueva oferta e invalida el flujo reactivo
  Future<void> proposeNewOffer({
    required String receiverId,
    required String senderProductId,
    required String receiverProductId,
    required double additionalCash,
  }) async {
    try {
      final repo = ref.read(tradeOfferRepositoryProvider);
      await repo.createOffer(
        receiverId: receiverId,
        senderProductId: senderProductId,
        receiverProductId: receiverProductId,
        additionalCash: additionalCash,
      );
      await _loadOffers();
    } catch (e, st) {
      _controller.addError(e, st);
    }
  }

  /// Resuelve el flujo de aceptación o rechazo de una oferta de intercambio
  Future<void> resolveOffer(String offerId, TradeOfferStatus newStatus) async {
    try {
      final repo = ref.read(tradeOfferRepositoryProvider);
      await repo.updateOfferStatus(offerId, newStatus);
      await _loadOffers();
    } catch (e, st) {
      _controller.addError(e, st);
    }
  }
}

/// Declaración explícita del StreamNotifierProvider en su variante autoDispose
final userTradeOffersProvider =
    StreamNotifierProvider.autoDispose<
      UserTradeOffersNotifier,
      List<TradeOffer>
    >(() {
      return UserTradeOffersNotifier();
    });
