import 'package:flutter/material.dart';

import 'chat_detail_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const conversations = [
    _Conversation(
      name: 'Carlos',
      product: 'iPhone 14 Pro',
      message: 'Hola, ¿te interesa el MacBook Air M2?',
      time: '10:42',
      unread: true,
    ),
    _Conversation(
      name: 'Laura',
      product: 'Cámara Sony Alpha',
      message: 'Podemos hablar del intercambio.',
      time: 'Ayer',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversations.length,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = conversations[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 26,
              child: Text(
                conversation.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.name,
                    style: TextStyle(
                      fontWeight: conversation.unread
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  conversation.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${conversation.product}\n${conversation.message}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: conversation.unread
                ? const CircleAvatar(
                    radius: 5,
                    child: SizedBox(),
                  )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(
                    name: conversation.name,
                    product: conversation.product,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.name,
    required this.product,
    required this.message,
    required this.time,
    required this.unread,
  });

  final String name;
  final String product;
  final String message;
  final String time;
  final bool unread;
}
