import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chat_conversation.dart';
import '../../../models/chat_message.dart';
import '../../../models/product.dart';
import '../../../core/supabase/supabase_client.dart';
import '../repositories/chat_repository.dart';

final authUserIdProvider = Provider<AsyncValue<String?>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AsyncValue.data(client.auth.currentUser?.id);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatRepository(client);
});

final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, conversationId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamMessages(conversationId);
    });

final chatSendProvider = Provider<Future<void> Function(String, String)>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return (String conversationId, String text) async {
    await repository.addMessage(conversationId: conversationId, text: text);
  };
});

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

  Future<void> addMessage({
    required String conversationId,
    required String text,
  }) async {
    await _repository.addMessage(conversationId: conversationId, text: text);
  }
}

final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatConversation>>(
      ChatNotifier.new,
    );
