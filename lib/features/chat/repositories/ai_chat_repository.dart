import 'package:dart_openai/dart_openai.dart';
import '../../../models/chat_message.dart';

class AiChatRepository {
  void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
  }

  Future<String> sendMessageToAgent({
    required List<ChatMessage> history,
    String? systemInstructions,
  }) async {
    try {
      final messages = <OpenAIChatCompletionChoiceMessageModel>[];

      if (systemInstructions != null) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemInstructions,
              ),
            ],
          ),
        );
      }

      for (final msg in history) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: msg.isMine
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text),
            ],
          ),
        );
      }

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7,
      );

      return chatCompletion.choices.first.message.content?.first.text ??
          "Lo siento, no he podido procesar tu solicitud.";
    } catch (e) {
      return "Error de conexión con el Agente: $e";
    }
  }
}
