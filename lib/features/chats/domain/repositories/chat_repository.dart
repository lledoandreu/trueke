import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRepository {
  /// Obtiene o crea una sala de chat entre dos usuarios para un producto específico.
  Future<Chat> getOrCreateChat({
    required String productId,
    required String sellerId,
    required String buyerId,
  });

  /// Transmite un flujo en tiempo real con la lista de salas de chat de un usuario.
  Stream<List<Chat>> streamUserChats(String userId);

  /// Transmite un flujo en tiempo real con los mensajes de una sala de chat específica.
  Stream<List<Message>> streamMessages(String chatId);

  /// Envía un mensaje de texto dentro de una sala de chat.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
}
