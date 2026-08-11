import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.name,
    required this.product,
    required this.messages,
  });

  final String id;
  final String name;
  final String product;
  final List<ChatMessage> messages;

  ChatConversation copyWith({
    List<ChatMessage>? messages,
  }) {
    return ChatConversation(
      id: id,
      name: name,
      product: product,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'product': product,
    'messages': messages.map((message) => message.toJson()).toList(),
  };

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      name: json['name'] as String,
      product: json['product'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map(
            (item) => ChatMessage.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class ChatNotifier extends AsyncNotifier<List<ChatConversation>> {
  static const _storageKey = 'chat_conversations';

  @override
  Future<List<ChatConversation>> build() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);

    if (saved == null) {
      return _initialConversations();
    }

    final decoded = jsonDecode(saved) as List<dynamic>;

    return decoded
        .map(
          (item) => ChatConversation.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<String> startConversation({
    required String productId,
    required String productTitle,
    required String owner,
    required String message,
  }) async {
    final conversations = state.valueOrNull ?? _initialConversations();

    final existingIndex = conversations.indexWhere(
      (conversation) =>
          conversation.id == 'product-$productId',
    );

    if (existingIndex != -1) {
      final conversation = conversations[existingIndex];

      final updatedConversation = conversation.copyWith(
        messages: [
          ...conversation.messages,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: message,
            isMine: true,
            createdAt: DateTime.now(),
          ),
        ],
      );

      final updated = [...conversations];
      updated[existingIndex] = updatedConversation;

      state = AsyncData(updated);
      await _save(updated);

      return updatedConversation.id;
    }

    final conversation = ChatConversation(
      id: 'product-$productId',
      name: owner,
      product: productTitle,
      messages: [
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: message,
          isMine: true,
          createdAt: DateTime.now(),
        ),
      ],
    );

    final updated = [
      conversation,
      ...conversations,
    ];

    state = AsyncData(updated);
    await _save(updated);

    return conversation.id;
  }

  Future<void> addMessage({
    required String conversationId,
    required String text,
  }) async {
    final conversations = state.valueOrNull ?? _initialConversations();

    final updated = conversations.map((conversation) {
      if (conversation.id != conversationId) {
        return conversation;
      }

      return conversation.copyWith(
        messages: [
          ...conversation.messages,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: text,
            isMine: true,
            createdAt: DateTime.now(),
          ),
        ],
      );
    }).toList();

    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> _save(List<ChatConversation> conversations) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _storageKey,
      jsonEncode(
        conversations.map((conversation) => conversation.toJson()).toList(),
      ),
    );
  }

  List<ChatConversation> _initialConversations() {
    return [
      ChatConversation(
        id: 'carlos-iphone',
        name: 'Carlos',
        product: 'iPhone 14 Pro',
        messages: [
          ChatMessage(
            id: 'carlos-1',
            text: 'Hola, ¿te interesa mi artículo?',
            isMine: false,
            createdAt: DateTime.now(),
          ),
          ChatMessage(
            id: 'carlos-2',
            text: 'Sí, me interesa. ¿Te gustaría hacer un intercambio?',
            isMine: true,
            createdAt: DateTime.now(),
          ),
        ],
      ),
      ChatConversation(
        id: 'laura-camera',
        name: 'Laura',
        product: 'Cámara Sony Alpha',
        messages: [
          ChatMessage(
            id: 'laura-1',
            text: 'Podemos hablar del intercambio.',
            isMine: false,
            createdAt: DateTime.now(),
          ),
        ],
      ),
    ];
  }
}

final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatConversation>>(
  ChatNotifier.new,
);
