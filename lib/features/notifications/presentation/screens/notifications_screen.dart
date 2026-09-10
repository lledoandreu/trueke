import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notifications/providers/notifications_history_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          notificationsAsync.maybeWhen(
            data: (list) => list.any((n) => !n.isRead)
                ? IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: 'Marcar todo como leído',
                    onPressed: () => ref
                        .read(notificationsHistoryProvider.notifier)
                        .markAllAsRead(),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tu bandeja de entrada está vacía',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsHistoryProvider.future),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  color: notification.isRead
                      ? Colors.transparent
                      : Colors.blue.withValues(alpha: 0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification.isRead
                          ? Colors.grey.shade200
                          : Colors.blue.shade100,
                      child: Icon(
                        _getIconForType(notification.type),
                        color: notification.isRead
                            ? Colors.grey
                            : Colors.blue.shade800,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                      ],
                    ),
                    trailing: !notification.isRead
                        ? IconButton(
                            icon: const Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 12,
                            ),
                            onPressed: () => ref
                                .read(notificationsHistoryProvider.notifier)
                                .markAsRead(notification.id),
                          )
                        : null,
                    onTap: () {
                      if (!notification.isRead) {
                        ref
                            .read(notificationsHistoryProvider.notifier)
                            .markAsRead(notification.id);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error al cargar notificaciones: $error')),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'exchange':
        return Icons.swap_horizontal_circle_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_none;
    }
  }
}
