import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/providers/chat_provider.dart';
import 'package:trueke/features/chat/providers/ai_chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final TextEditingController _aiTextController;

  @override
  void initState() {
    super.initState();
    _aiTextController = TextEditingController();
  }

  @override
  void dispose() {
    _aiTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiChatMessages = ref.watch(aiChatProvider);
    final userConversations = ref.watch(chatProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Mensajes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble), text: 'Mensajes'),
              Tab(icon: Icon(Icons.smart_toy), text: 'Trueki IA'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- PESTAÑA 1: CHATS ENTRE USUARIOS ---
            userConversations.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const Center(
                    child: Text('Aún no tienes conversaciones de trueque.'),
                  );
                }
                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(conversation.product),
                      subtitle: Text(
                        conversation.lastMessageText ?? 'No hay mensajes.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navegación hacia la subpantalla chat_detail_page.dart
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error al cargar conversaciones: $err')),
            ),

            // --- PESTAÑA 2: ASISTENTE TRUEKI IA ---
            Column(
              children: [
                Expanded(
                  child: aiChatMessages.isEmpty
                      ? const Center(
                          child: Text('¡Hola! Pregúntame sobre trueques.'),
                        )
                      : ListView.builder(
                          itemCount: aiChatMessages.length,
                          itemBuilder: (context, index) {
                            final message = aiChatMessages[index];
                            final isUser =
                                message is Map && message['role'] == 'user';
                            final content = message is Map
                                ? (message['content']?.toString() ?? '')
                                : '';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              child: Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.blue[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
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
                          controller: _aiTextController,
                          decoration: const InputDecoration(
                            hintText: 'Pregunta algo sobre un trueque...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = _aiTextController.text.trim();
                          if (text.isNotEmpty) {
                            ref
                                .read(aiChatProvider.notifier)
                                .sendUserMessage(text);
                            _aiTextController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
