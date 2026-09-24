import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/chat_conversation.dart';
import '../domain/models/chat_message.dart';
import '../domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;
  static const _conversationsTable = 'conversations';
  static const _messagesTable = 'messages';

  SupabaseChatRepository(this._client);

  @override
  Future<ChatConversation> getOrCreateChat({
    required String productId,
    required String sellerId,
    required String buyerId,
  }) async {
    final response = await _client
        .from(_conversationsTable)
        .select()
        .eq('product_id', productId)
        .eq('buyer_id', buyerId)
        .maybeSingle();

    final currentUserId = _client.auth.currentUser?.id ?? '';

    if (response != null) {
      return ChatConversation.fromJson(response, currentUserId: currentUserId);
    }

    // Nota: El modelo requiere buyer_name y seller_name, se inyectan valores base o el trigger los actualiza
    final newChatData = {
      'product_id': productId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'buyer_name': 'Usuario',
      'seller_name': 'Usuario',
      'created_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from(_conversationsTable)
        .insert(newChatData)
        .select()
        .single();
    return ChatConversation.fromJson(inserted, currentUserId: currentUserId);
  }

  @override
  Stream<List<ChatConversation>> streamUserChats(String userId) {
    return _client
        .from(_conversationsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) {
          return maps
              .where((map) {
                final buyerId = map['buyer_id'] as String?;
                final sellerId = map['seller_id'] as String?;
                return buyerId == userId || sellerId == userId;
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
        .eq('conversation_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) {
          return maps.map((map) {
            // Mapeamos dinámicamente conversation_id a chat_id para compatibilidad con el modelo actual
            final modifiedMap = Map<String, dynamic>.from(map);
            modifiedMap['chat_id'] = map['conversation_id'];
            return ChatMessage.fromJson(
              modifiedMap,
              currentUserId: currentUserId,
            );
          }).toList();
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
      'conversation_id': chatId,
      'sender_id': senderId,
      'text': text.trim(),
      'created_at': now,
    });
  }
}
