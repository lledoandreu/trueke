import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../models/chat_message.dart';
import '../repositories/ai_chat_repository.dart';

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AiChatRepository(client);
});

class AiChatNotifier extends Notifier<List<dynamic>> {
  @override
  List<dynamic> build() => [];

  void addMessage(dynamic message) {
    state = [...state, message];
  }

  void clearChat() {
    state = [];
  }

  Future<void> sendUserMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    // 1. Agregar el mensaje del usuario localmente
    final userMsg = {"role": "user", "content": trimmed};
    state = [...state, userMsg];

    // 2. Mapear el historial dinámico a objetos ChatMessage que espera el repositorio
    final history = state.map((item) {
      final map = item as Map<String, dynamic>;
      final isMine = map['role'] == 'user';
      return ChatMessage(
        id: DateTime.now().toIso8601String(),
        text: map['content'] as String,
        isMine: isMine,
        createdAt: DateTime.now(),
      );
    }).toList();

    try {
      final repository = ref.read(aiChatRepositoryProvider);
      final responseText = await repository.sendMessageToAgent(
        history: history,
      );

      // 3. Agregar la respuesta del asistente virtual
      state = [
        ...state,
        {"role": "assistant", "content": responseText},
      ];
    } catch (_) {
      state = [
        ...state,
        {
          "role": "assistant",
          "content":
              "Lo siento, ha ocurrido un error al conectar con Trueki IA.",
        },
      ];
    }
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, List<dynamic>>(
  AiChatNotifier.new,
);
