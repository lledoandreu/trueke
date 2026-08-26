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
    });
  }
}
