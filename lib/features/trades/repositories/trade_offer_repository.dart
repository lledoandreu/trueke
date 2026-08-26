import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/product.dart';
import '../../../models/trade_offer.dart';
import '../../auth/auth_service.dart';
import '../../chat/repositories/chat_repository.dart';

class TradeOfferRepository {
  TradeOfferRepository({SupabaseClient? client, ChatRepository? chatRepository})
    : _client = client ?? Supabase.instance.client,
      _chatRepository = chatRepository ?? ChatRepository();

  final SupabaseClient _client;
  final ChatRepository _chatRepository;

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
    final userId = AuthService.currentUserId;
    if (userId == null) {
      throw StateError('Debes iniciar sesión para enviar una propuesta.');
    }

    final conversationId = await _chatRepository.startConversation(
      product: product,
      message: message,
    );

    await _client.from(_table).insert({
      'product_id': product.id,
      'product_title': product.title,
      'from_user_id': userId,
      'to_user_id': product.ownerId,
      'conversation_id': conversationId,
      'message': message,
      'status': TradeOfferStatus.sent.name,
      'offered_product_id': offeredProduct?.id,
      'offered_product_title': offeredProduct?.title,
    });
  }

  Future<TradeOffer> updateStatus({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      throw StateError('Debes iniciar sesión para responder a una propuesta.');
    }

    if (!offer.isIncoming) {
      throw StateError('Solo el destinatario puede aceptar o rechazar.');
    }

    if (!offer.isPending) {
      throw StateError('Esta propuesta ya está respondida.');
    }

    await _client
        .from(_table)
        .update({'status': status.name})
        .eq('id', offer.id)
        .eq('to_user_id', userId);

    final conversationId = offer.conversationId;
    if (conversationId != null) {
      final text = status == TradeOfferStatus.accepted
          ? 'He aceptado tu propuesta de intercambio.'
          : 'He rechazado tu propuesta de intercambio.';

      await _chatRepository.addMessage(
        conversationId: conversationId,
        text: text,
      );
    }

    return offer.copyWith(status: status);
  }
}
