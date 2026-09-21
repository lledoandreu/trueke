import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/chat_conversation.dart';
import '../domain/models/chat_message.dart';
import '../domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;
  static const _chatsTable = 'chats';
  static const _messagesTable = 'messages';

  SupabaseChatRepository(this._client);

  @override
  Future<ChatConversation> getOrCreateChat({
    required String productId,
    required String sellerId,
    required String buyerId,
  }) async {
    final response = await _client
        .from(_chatsTable)
        .select()
        .eq('product_id', productId)
        .contains('participant_ids', [buyerId])
        .maybeSingle();

    final currentUserId = _client.auth.currentUser?.id ?? '';

    if (response != null) {
      return ChatConversation.fromJson(response, currentUserId: currentUserId);
    }

    final newChatData = {
      'product_id': productId,
      'participant_ids': [buyerId, sellerId],
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from(_chatsTable)
        .insert(newChatData)
        .select()
        .single();
    return ChatConversation.fromJson(inserted, currentUserId: currentUserId);
  }

  @override
  Stream<List<ChatConversation>> streamUserChats(String userId) {
    return _client
        .from(_chatsTable)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((maps) {
          return maps
              .where((map) {
                final participants = map['participant_ids'] as List<dynamic>?;
                return participants?.contains(userId) ?? false;
              })
              .map(
                (map) => ChatConversation.fromJson(map, currentUserId: userId),
              )
              .toList();
        });
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    final currentUserId = _client.auth.currentUser?.id ?? '';
    return _client
        .from(_messagesTable)
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) {
          return maps
              .map(
                (map) =>
                    ChatMessage.fromJson(map, currentUserId: currentUserId),
              )
              .toList();
        });
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final now = DateTime.now().toIso8601String();

    await _client.from(_messagesTable).insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'text': text.trim(),
      'created_at': now,
    });

    await _client
        .from(_chatsTable)
        .update({'updated_at': now})
        .eq('id', chatId);
  }
}
