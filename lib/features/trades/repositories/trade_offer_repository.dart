import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/product.dart';
import '../../../models/trade_offer.dart';
import '../../auth/auth_service.dart';

class TradeOfferRepository {
  TradeOfferRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'trade_offers';

  Future<List<TradeOffer>> getOffers() async {
    final userId = AuthService.currentUserId;

    if (userId == null) {
      return [];
    }

    final response = await _client
        .from(_table)
        .select()
        .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => TradeOffer.fromJson(
            item as Map<String, dynamic>,
            currentUserId: userId,
          ),
        )
        .toList();
  }

  Future<void> sendOffer({
    required Product product,
    required String message,
    Product? offeredProduct,
  }) async {
    if (AuthService.currentUserId == null) {
      throw StateError('Debes iniciar sesión para enviar una propuesta.');
    }

    await _client.rpc<void>(
      'create_trade_offer',
      params: {
        'p_product_id': product.id,
        'p_message': message,
        'p_offered_product_id': offeredProduct?.id,
      },
    );
  }

  Future<TradeOffer> updateStatus({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    if (AuthService.currentUserId == null) {
      throw StateError('Debes iniciar sesión para responder a una propuesta.');
    }

    if (!offer.isIncoming) {
      throw StateError('Solo el destinatario puede aceptar o rechazar.');
    }

    if (!offer.isPending) {
      throw StateError('Esta propuesta ya está respondida.');
    }

    if (status != TradeOfferStatus.accepted &&
        status != TradeOfferStatus.rejected) {
      throw StateError(
        'Solo se puede aceptar o rechazar una propuesta pendiente.',
      );
    }

    await _client.rpc<void>(
      'respond_to_trade_offer',
      params: {'p_offer_id': offer.id, 'p_status': status.name},
    );

    return offer.copyWith(status: status);
  }
}
