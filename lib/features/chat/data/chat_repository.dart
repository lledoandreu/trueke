import '../models/chat_room.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<ChatRoom> getOrCreateChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
  });

  Stream<List<ChatMessage>> streamMessages(String roomId);

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String message,
  });

  Stream<List<ChatRoom>> streamUserChatRooms(String userId);
}
