import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/models/chat_conversation.dart';
import 'package:trueke/models/chat_message.dart';

void main() {
  group('Chat Models Unit Tests', () {
    test(
      'ChatMessage.fromJson parses correct isMine data based on currentUserId',
      () {
        final json = {
          'id': 'msg-1',
          'text': '¿Te interesa una permuta?',
          'sender_id': 'user-123',
          'created_at': '2026-09-09T20:00:00.000Z',
        };

        final messageMine = ChatMessage.fromJson(
          json,
          currentUserId: 'user-123',
        );
        final messageNotMine = ChatMessage.fromJson(
          json,
          currentUserId: 'user-999',
        );

        expect(messageMine.isMine, isTrue);
        expect(messageNotMine.isMine, isFalse);
        expect(messageMine.text, '¿Te interesa una permuta?');
      },
    );

    test(
      'ChatConversation.fromJson dynamically determines names and chronological sort',
      () {
        final json = {
          'id': 'conv-123',
          'product_id': 'prod-456',
          'product_title': 'Consola Retro',
          'buyer_id': 'user-buyer',
          'seller_id': 'user-seller',
          'buyer_name': 'Juan Comprador',
          'seller_name': 'María Vendedora',
          'messages': [
            {
              'id': 'msg-2',
              'text': 'Segundo mensaje',
              'sender_id': 'user-seller',
              'created_at': '2026-09-09T21:05:00.000Z',
            },
            {
              'id': 'msg-1',
              'text': 'Primer mensaje',
              'sender_id': 'user-buyer',
              'created_at': '2026-09-09T21:00:00.000Z',
            },
          ],
        };

        // Si el usuario actual es el comprador, el nombre de la conversación debe ser el del vendedor
        final conversationForBuyer = ChatConversation.fromJson(
          json,
          currentUserId: 'user-buyer',
        );
        expect(conversationForBuyer.name, 'María Vendedora');

        // Si el usuario actual es el vendedor, el nombre de la conversación debe ser el del comprador
        final conversationForSeller = ChatConversation.fromJson(
          json,
          currentUserId: 'user-seller',
        );
        expect(conversationForSeller.name, 'Juan Comprador');

        // Verificar que los mensajes se ordenen cronológicamente (msg-1 antes de msg-2)
        expect(conversationForBuyer.messages.first.id, 'msg-1');
        expect(conversationForBuyer.messages.last.id, 'msg-2');
        expect(conversationForBuyer.lastMessageText, 'Segundo mensaje');
      },
    );

    test('ChatConversation.copyWith clones structure correctly', () {
      const conversation = ChatConversation(
        id: 'conv-abc',
        name: 'Luis',
        product: 'Teclado Mecánico',
        messages: [],
      );

      final updated = conversation.copyWith(
        messages: [
          ChatMessage(
            id: 'msg-new',
            text: 'Nuevo',
            isMine: true,
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(conversation.messages.isEmpty, isTrue);
      expect(updated.messages.length, 1);
      expect(updated.id, 'conv-abc');
    });
  });
}
