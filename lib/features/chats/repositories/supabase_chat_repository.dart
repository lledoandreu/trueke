import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/chat_model.dart';
import '../domain/models/message_model.dart';
import '../domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;

  SupabaseChatRepository(this._client);

  static const _chatsTable = 'chats';
  static const _messagesTable = 'messages';

  @override
  Future<Chat> getOrCreateChat({
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

    if (response != null) {
      return Chat.fromJson(response);
    }

    final newChatId =
        '${DateTime.now().millisecondsSinceEpoch}_${productId.substring(0, 4)}';
    final newChatData = {
      'id': newChatId,
      'product_id': productId,
      'participant_ids': [buyerId, sellerId],
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from(_chatsTable).insert(newChatData);
    return Chat.fromJson(newChatData);
  }

  @override
  Stream<List<Chat>> streamUserChats(String userId) {
    return _client
        .from(_chatsTable)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((maps) {
          return maps
              .map((map) => Chat.fromJson(map))
              .where((chat) => chat.participantIds.contains(userId))
              .toList();
        });
  }

  @override
  Stream<List<Message>> streamMessages(String chatId) {
    return _client
        .from(_messagesTable)
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((maps) {
          return maps.map((map) => Message.fromJson(map)).toList();
        });
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final now = DateTime.now().toIso8601String();
    final messageId = '${DateTime.now().millisecondsSinceEpoch}_$senderId';

    await _client.from(_messagesTable).insert({
      'id': messageId,
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
