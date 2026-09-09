import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiChatProvider = NotifierProvider<AiChatNotifier, List<dynamic>>(
  AiChatNotifier.new,
);

class AiChatNotifier extends Notifier<List<dynamic>> {
  @override
  List<dynamic> build() => [];

  void addMessage(dynamic message) {
    state = [...state, message];
  }

  void clearChat() {
    state = [];
  }

  // Método requerido por tu chat_page.dart
  Future<void> sendUserMessage(String message) async {
    // Añade el mensaje del usuario al estado de forma local
    addMessage({"role": "user", "content": message});

    // Aquí puedes añadir la lógica futura con tu repositorio de IA o Supabase
  }
}
