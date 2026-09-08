import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/providers/ai_chat_provider.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(aiChatProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Asistente de Trueques')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                final isUser = message is Map && message['role'] == 'user';
                final content = message is Map ? (message['content']?.toString() ?? '') : '';

                return ListTile(
                  title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      child: Text(content),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(hintText: 'Pregunta algo sobre un trueque...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      ref.read(aiChatProvider.notifier).sendUserMessage(textController.text.trim());
                      textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
