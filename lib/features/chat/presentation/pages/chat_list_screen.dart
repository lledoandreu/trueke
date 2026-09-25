import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../models/transaction.dart'; // Corregido con un nivel más para llegar a la raíz
import '../../providers/chat_providers.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final currentUserId = client.auth.currentUser?.id;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final chatRoomsAsync = ref.watch(
      userChatRoomsStreamProvider(currentUserId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Conversaciones')),
      body: chatRoomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Text('No tienes conversaciones activas todavía'),
            );
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ChatRoomTile(room: room, currentUserId: currentUserId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class ChatRoomTile extends ConsumerWidget {
  final dynamic room;
  final String currentUserId;

  const ChatRoomTile({
    super.key,
    required this.room,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peerId = room.buyerId == currentUserId ? room.sellerId : room.buyerId;

    final productAsync = ref.watch(chatProductProvider(room.productId));
    final peerProfileAsync = ref.watch(userProfileProvider(peerId));
    final txStatus = ref.watch(
      chatRoomTransactionStatusProvider(room.productId),
    );

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.broken_image_outlined),
            ),
            title: const Text('Producto no disponible'),
            subtitle: const Text('El artículo ya no existe o fue eliminado'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToChat(context),
          );
        }

        final productImg = product.imageUrl;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: Colors.grey,
              child: productImg.isNotEmpty
                  ? Image.network(
                      productImg,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (txStatus == TransactionStatus.accepted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    'RESERVADO',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (txStatus == TransactionStatus.completed)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    'TRUECADO',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: peerProfileAsync.when(
            data: (profile) => Text(
              'Con: ${profile.displayName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            loading: () => const Text(
              'Cargando usuario...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            error: (err, stack) => const Text(
              'Con: Usuario Trueke',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToChat(context),
        );
      },
      loading: () => const ListTile(
        leading: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        title: Text('Cargando conversación...'),
      ),
      error: (err, stack) => ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.error_outline, color: Colors.white),
        ),
        title: const Text('Error al cargar datos del chat'),
        subtitle: Text('$err', maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => _navigateToChat(context),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(roomId: room.id)),
    );
  }
}
