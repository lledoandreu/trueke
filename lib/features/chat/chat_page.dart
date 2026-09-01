import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/ai_chat_provider.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(aiChatProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Trueques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(aiChatProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatMessages.isEmpty
                ? const Center(
                    child: Text(
                      '¡Hola! Soy Trueki. ¿En qué puedo ayudarte con tus intercambios hoy?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessages[index];

                      return Align(
                        alignment: message.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: message.isMine
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isMine
                                  ? Colors.white
                                  : Colors.black87,
                            ),
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
                    decoration: const InputDecoration(
                      hintText: 'Pregúntame sobre trueques, tasaciones...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        ref
                            .read(aiChatProvider.notifier)
                            .sendUserMessage(value);
                        textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blueAccent,
                  onPressed: () {
                    final text = textController.text;
                    if (text.trim().isNotEmpty) {
                      ref.read(aiChatProvider.notifier).sendUserMessage(text);
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
