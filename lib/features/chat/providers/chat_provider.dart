import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chat_conversation.dart';
import '../../../models/product.dart';
import '../repositories/chat_repository.dart';

class ChatNotifier extends AsyncNotifier<List<ChatConversation>> {
  ChatRepository get _repository => ChatRepository();

  @override
  Future<List<ChatConversation>> build() {
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

    state = AsyncData(await _repository.getConversations());
  }
}

final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatConversation>>(
      ChatNotifier.new,
    );
