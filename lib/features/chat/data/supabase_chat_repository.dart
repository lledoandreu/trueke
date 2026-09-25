import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import 'chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;

  SupabaseChatRepository(this._client);

  @override
  Future<ChatRoom> getOrCreateChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
  }) async {
    // 1. Intentar buscar si ya existe la sala de chat
    final response = await _client
        .from('chat_rooms')
        .select()
        .eq('product_id', productId)
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .maybeSingle();

    if (response != null) {
      return ChatRoom.fromJson(response);
    }

    // 2. Si no existe, crear una nueva sala
    final newRoomResponse = await _client
        .from('chat_rooms')
        .insert({
          'product_id': productId,
          'buyer_id': buyerId,
          'seller_id': sellerId,
        })
        .select()
        .single();

    return ChatRoom.fromJson(newRoomResponse);
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((maps) => maps.map((map) => ChatMessage.fromJson(map)).toList());
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String message,
  }) async {
    await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': senderId,
      'message': message,
    });
  }

  @override
  Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (maps) => maps
              .map((map) => ChatRoom.fromJson(map))
              .where(
                (room) => room.buyerId == userId || room.sellerId == userId,
              )
              .toList(),
        );
  }
}
