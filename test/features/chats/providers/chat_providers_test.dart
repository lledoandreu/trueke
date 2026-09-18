import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueke/features/chats/domain/models/chat_conversation.dart';
import 'package:trueke/features/chats/domain/models/chat_message.dart';
import 'package:trueke/features/chats/domain/repositories/chat_repository.dart';
import 'package:trueke/features/chats/providers/chat_providers.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;
  late ProviderContainer container;

  final sampleConversations = const <ChatConversation>[
    ChatConversation(
      id: 'chat_001',
      name: 'Juan Pérez',
      product: 'Bicicleta de montaña',
      productId: 'prod_123',
      sellerId: 'seller_456',
      buyerId: 'user_123',
      messages: [],
    ),
  ];

  final sampleMessages = <ChatMessage>[
    ChatMessage(
      id: 'msg_001',
      chatId: 'chat_001',
      senderId: 'user_123',
      text: 'Hola, sigue disponible?',
      isMine: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  setUp(() {
    mockChatRepository = MockChatRepository();
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'userChatsStreamProvider debe emitir la lista de chats desde el repositorio manteniendo vivo el estado',
    () async {
      when(
        () => mockChatRepository.streamUserChats('user_123'),
      ).thenAnswer((_) => Stream.value(sampleConversations));

      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(mockChatRepository),
        ],
      );

      final keepAliveListener = container.listen(
        userChatsStreamProvider('user_123'),
        (_, _) {},
      );

      final result = await container.read(
        userChatsStreamProvider('user_123').future,
      );

      expect(result, sampleConversations);
      verify(() => mockChatRepository.streamUserChats('user_123')).called(1);

      keepAliveListener.close();
    },
  );

  test(
    'chatMessagesStreamProvider debe emitir la lista de mensajes manteniendo vivo el estado',
    () async {
      when(
        () => mockChatRepository.streamMessages('chat_001'),
      ).thenAnswer((_) => Stream.value(sampleMessages));

      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(mockChatRepository),
        ],
      );

      final keepAliveListener = container.listen(
        chatMessagesStreamProvider('chat_001'),
        (_, _) {},
      );

      final result = await container.read(
        chatMessagesStreamProvider('chat_001').future,
      );

      expect(result, sampleMessages);
      verify(() => mockChatRepository.streamMessages('chat_001')).called(1);

      keepAliveListener.close();
    },
  );
}
