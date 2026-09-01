import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/chat_message.dart';
import '../repositories/ai_chat_repository.dart';

final aiChatRepositoryProvider = Provider((ref) => AiChatRepository());

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<ChatMessage>>(
  (ref) {
    final repository = ref.watch(aiChatRepositoryProvider);
    return AiChatNotifier(repository);
  },
);

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AiChatRepository _repository;
  final _supabase = Supabase.instance.client;

  AiChatNotifier(this._repository) : super([]) {
    const apiKey = String.fromEnvironment(
      'OPENAI_API_KEY',
      defaultValue: 'TU_OPENAI_API_KEY_TEMPORAL',
    );
    _repository.initialize(apiKey);
  }

  final String _systemInstructions =
      "Eres Trueki, el asistente inteligente de la app Trueke. "
      "Tu objetivo es ayudar a los usuarios a negociar de forma justa, tasar productos y "
      "sugerir intercambios equitativos. Sé amable, dinámico y conciso.";

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userId = _supabase.auth.currentUser?.id ?? 'usuario_anonimo';
    final timestamp = DateTime.now();

    final userMessage = ChatMessage(
      id: timestamp.millisecondsSinceEpoch.toString(),
      text: text,
      isMine: true,
      createdAt: timestamp,
      senderId: userId,
    );

    state = [...state, userMessage];

    final botResponseText = await _repository.sendMessageToAgent(
      history: state,
      systemInstructions: _systemInstructions,
    );

    final botTimestamp = DateTime.now();

    final agentMessage = ChatMessage(
      id: botTimestamp.millisecondsSinceEpoch.toString(),
      text: botResponseText,
      isMine: false,
      createdAt: botTimestamp,
      senderId: 'trueki_agent_id',
    );

    state = [...state, agentMessage];
  }

  void clearChat() {
    state = [];
  }
}
