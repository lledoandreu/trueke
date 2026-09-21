import '../../../core/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_conversation.dart';
import '../domain/models/chat_message.dart';
import '../domain/repositories/chat_repository.dart';
import '../repositories/supabase_chat_repository.dart';

final chatRepositoryProvider = Provider.autoDispose<ChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatRepository(client);
});

final userChatsStreamProvider = StreamProvider.autoDispose
    .family<List<ChatConversation>, String>((ref, userId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamUserChats(userId);
    });

final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, chatId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamMessages(chatId);
    });
