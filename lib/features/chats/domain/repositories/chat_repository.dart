import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<ChatConversation> getOrCreateChat({
    required String productId,
    required String sellerId,
    required String buyerId,
  });
  Stream<List<ChatConversation>> streamUserChats(String userId);
  Stream<List<ChatMessage>> streamMessages(String chatId);
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
}
