import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import '../providers/chat_providers.dart';
import 'chat_detail_page.dart';

class ChatsListPage extends ConsumerWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Debes iniciar sesión para ver tus conversaciones.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final chatsAsync = ref.watch(userChatsStreamProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Conversaciones')),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text('No tienes chats activos todavía.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final displayMessage =
                  chat.lastMessage?.text ?? 'Conversación vacía';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  title: Text(
                    'Trueke por producto: ${chat.productId.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    displayMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(chat: chat),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error al cargar conversaciones: $err')),
      ),
    );
  }
}
