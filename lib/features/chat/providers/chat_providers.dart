import '../models/chat_room.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/chat_repository.dart';
import '../data/supabase_chat_repository.dart';
import '../models/chat_message.dart';

/// Proveedor del repositorio de chat
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatRepository(client);
});

/// Proveedor reactivo del flujo de mensajes de una sala en tiempo real (requiere roomId)
final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamMessages(roomId);
    });

final userChatRoomsStreamProvider =
    StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamUserChatRooms(userId);
    });
