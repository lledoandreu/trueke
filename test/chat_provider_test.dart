import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/providers/chat_provider.dart';
import 'package:trueke/features/chat/repositories/chat_repository.dart';
import 'package:trueke/models/chat_conversation.dart';
import 'package:trueke/models/chat_message.dart';
import 'package:trueke/models/product.dart';

class FakeChatRepository implements ChatRepository {
  final List<String> sentMessages = [];
  final StreamController<List<ChatMessage>> _controller =
      StreamController<List<ChatMessage>>.broadcast();

  void emitMessages(List<ChatMessage> messages) {
    _controller.add(messages);
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _controller.stream;
  }

  @override
  Future<void> addMessage({
    required String conversationId,
    required String text,
  }) async {
    sentMessages.add('$conversationId:$text');
  }

  @override
  Future<List<ChatConversation>> getConversations() async {
    return const [
      ChatConversation(
        id: 'conv-1',
        name: 'Carlos',
        product: 'Bicicleta de montaña',
        messages: [],
      ),
    ];
  }

  @override
  Future<String> startConversation({
    required Product product,
    required String message,
  }) async {
    sentMessages.add('${product.id}:$message');
    return 'conv-new';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ChatProvider & ChatMessagesStreamProvider', () {
    test('chatSendProvider delegates to repository addMessage', () async {
      final fakeRepo = FakeChatRepository();
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      final sendFn = container.read(chatSendProvider);
      await sendFn('conv-123', '¿Sigue disponible?');

      expect(fakeRepo.sentMessages, contains('conv-123:¿Sigue disponible?'));
    });

    test(
      'chatMessagesStreamProvider emits messages from repository stream',
      () async {
        final fakeRepo = FakeChatRepository();
        final container = ProviderContainer(
          overrides: [chatRepositoryProvider.overrideWithValue(fakeRepo)],
        );
        addTearDown(container.dispose);

        final streamSubscription = container.listen(
          chatMessagesStreamProvider('conv-123'),
          (_, _) {},
        );
        addTearDown(streamSubscription.close);

        final testMessage = ChatMessage(
          id: 'msg-1',
          text: 'Hola, ¿te interesa un cambio?',
          isMine: true,
          createdAt: DateTime.now(),
        );

        fakeRepo.emitMessages([testMessage]);
        await pumpEventQueue();

        final state = container.read(chatMessagesStreamProvider('conv-123'));
        expect(state.hasValue, isTrue);
        expect(state.value?.first.text, 'Hola, ¿te interesa un cambio?');
      },
    );
  });
}
