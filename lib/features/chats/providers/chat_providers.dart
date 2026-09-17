import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/providers/publish_product_provider.dart';
import '../domain/models/chat_model.dart';
import '../domain/models/message_model.dart';
import '../domain/repositories/chat_repository.dart';
import '../repositories/supabase_chat_repository.dart';

// Expone de forma limpia el repositorio de chats concretando la inyección de SupabaseClient
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatRepository(client);
});

// StreamProvider reactivo para escuchar la lista de conversaciones de un usuario específico
final userChatsStreamProvider = StreamProvider.family<List<Chat>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamUserChats(userId);
});

// StreamProvider reactivo para escuchar el flujo cronológico de mensajes en una sala específica
final chatMessagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, chatId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.streamMessages(chatId);
  },
);
