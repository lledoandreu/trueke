import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chat_conversation.dart';
import '../../../models/chat_message.dart';
import '../../../models/product.dart';
import '../../auth/auth_service.dart';
import '../repositories/chat_repository.dart';

/// Proveedor del repositorio de chat para inyección de dependencias.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Proveedor reactivo en tiempo real de mensajes para una conversación específica,
/// basado en Supabase Streams (`.stream`).
///
/// Se suscribe automáticamente al entrar y se cancela liberando recursos
/// cuando el widget se destruye (`autoDispose`).
final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, conversationId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamMessages(conversationId);
    });

/// Proveedor para enviar mensajes a una conversación delegando en el repositorio.
final chatSendProvider = Provider<Future<void> Function(String, String)>((ref) {
  final repository = ref.watch(chatRepositoryProvider);

  return (String conversationId, String text) async {
    await repository.addMessage(conversationId: conversationId, text: text);
  };
});

/// Notificador y estado reactivo para las conversaciones del usuario autenticado.
class ChatNotifier extends AsyncNotifier<List<ChatConversation>> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  @override
  Future<List<ChatConversation>> build() async {
    final userId = ref.watch(authUserIdProvider).value;

    if (userId == null) {
      return [];
    }

    return _repository.getConversations();
  }

  /// Inicia una conversación asociada a un producto o reutiliza la existente.
  Future<String> startConversation({
    required Product product,
    required String message,
  }) async {
    final conversationId = await _repository.startConversation(
      product: product,
      message: message,
    );

    state = AsyncData(await _repository.getConversations());
    return conversationId;
  }

  /// Envía un mensaje a la conversación.
  Future<void> addMessage({
    required String conversationId,
    required String text,
  }) async {
    await _repository.addMessage(conversationId: conversationId, text: text);
  }

  /// Métodos conservados para retrocompatibilidad
  void subscribeToConversation(String conversationId) {}
  void unsubscribeFromConversation(String conversationId) {}
}

/// Proveedor de la lista de conversaciones de chat del usuario.
final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatConversation>>(
      ChatNotifier.new,
    );
