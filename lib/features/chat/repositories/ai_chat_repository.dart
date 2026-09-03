import '../../../models/chat_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiChatRepository {
  AiChatRepository([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String> sendMessageToAgent({
    required List<ChatMessage> history,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'ai-chat',
        body: {
          'messages': [
            for (final message in history)
              {
                'role': message.isMine ? 'user' : 'assistant',
                'content': message.text,
              },
          ],
        },
      );

      final data = response.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }

      return 'Lo siento, no he podido procesar tu solicitud.';
    } on FunctionException {
      return 'Error de conexión con el asistente.';
    } catch (_) {
      return 'No se pudo conectar con el asistente.';
    }
  }
}
