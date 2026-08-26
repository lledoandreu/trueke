import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/chat_conversation.dart';
import '../../../models/chat_message.dart';
import '../../../models/product.dart';
import '../../auth/auth_service.dart';

class ChatRepository {
  ChatRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _conversations = 'conversations';
  static const _messages = 'messages';

  Future<List<ChatConversation>> getConversations() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      return [];
    }

    final response = await _client
        .from(_conversations)
        .select('*, messages(*)')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => ChatConversation.fromJson(
            item as Map<String, dynamic>,
            currentUserId: userId,
          ),
        )
        .toList();
  }

  Future<String> startConversation({
    required Product product,
    required String message,
  }) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      throw StateError('Debes iniciar sesión para enviar un mensaje.');
    }

    final existing = await _client
        .from(_conversations)
        .select()
        .eq('product_id', product.id)
        .eq('buyer_id', userId)
        .maybeSingle();

    if (existing != null) {
      final conversationId = existing['id'] as String;
      await addMessage(conversationId: conversationId, text: message);
      return conversationId;
    }

    final inserted = await _client
        .from(_conversations)
        .insert({
          'product_id': product.id,
          'product_title': product.title,
          'buyer_id': userId,
          'seller_id': product.ownerId,
          'buyer_name': AuthService.currentUserLabel,
          'seller_name': product.owner,
        })
        .select()
        .single();

    final conversationId = inserted['id'] as String;

    await addMessage(conversationId: conversationId, text: message);

    return conversationId;
  }

  Future<void> addMessage({
    required String conversationId,
    required String text,
  }) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      throw StateError('Debes iniciar sesión para enviar un mensaje.');
    }

    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return;
    }

    await _client.from(_messages).insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'text': cleanText,
    });
  }

  RealtimeChannel subscribeToMessages({
    required String conversationId,
    required void Function(ChatMessage message) onMessage,
  }) {
    return _client
        .channel('conversation:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _messages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final userId = AuthService.currentUserId;

            final message = ChatMessage.fromJson(
              payload.newRecord,
              currentUserId: userId,
            );

            onMessage(message);
          },
        )
        .subscribe();
  }

  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
