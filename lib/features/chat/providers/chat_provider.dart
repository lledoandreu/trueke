import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/chat_conversation.dart';
import '../../../models/chat_message.dart';
import '../../../models/product.dart';
import '../../auth/auth_service.dart';
import '../repositories/chat_repository.dart';

class ChatNotifier extends AsyncNotifier<List<ChatConversation>> {
  ChatRepository get _repository => ChatRepository();

  final Map<String, RealtimeChannel> _channels = {};

  @override
  Future<List<ChatConversation>> build() async {
    final userId = ref.watch(authUserIdProvider).valueOrNull;

    ref.onDispose(() async {
      for (final channel in _channels.values) {
        await _repository.unsubscribe(channel);
      }
      _channels.clear();
    });

    if (userId == null) {
      return [];
    }

    return _repository.getConversations();
  }

  void subscribeToConversation(String conversationId) {
    if (_channels.containsKey(conversationId)) {
      return;
    }

    final channel = _repository.subscribeToMessages(
      conversationId: conversationId,
      onMessage: (message) {
        _addRealtimeMessage(conversationId, message);
      },
    );

    _channels[conversationId] = channel;
  }

  void unsubscribeFromConversation(String conversationId) {
    final channel = _channels.remove(conversationId);

    if (channel != null) {
      _repository.unsubscribe(channel);
    }
  }

  void _addRealtimeMessage(String conversationId, ChatMessage message) {
    final conversations = state.valueOrNull;

    if (conversations == null) {
      return;
    }

    final updatedConversations = conversations.map((conversation) {
      if (conversation.id != conversationId) {
        return conversation;
      }

      final alreadyExists = conversation.messages.any(
        (item) => item.id == message.id,
      );

      if (alreadyExists) {
        return conversation;
      }

      return conversation.copyWith(
        messages: [...conversation.messages, message],
      );
    }).toList();

    state = AsyncData(updatedConversations);
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

    subscribeToConversation(conversationId);

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
