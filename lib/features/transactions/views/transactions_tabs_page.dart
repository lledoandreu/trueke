import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';

class TransactionsTabsPage extends ConsumerWidget {
  const TransactionsTabsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividad y Alertas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.notifications), text: 'Notificaciones'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
            ],
          ),
        ),
        body: TabBarView(children: [_NotificationsTab(), _HistoryTab()]),
      ),
    );
  }
}

class _NotificationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(
            child: Text('No tienes notificaciones pendientes.'),
          );
        }
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: notification.isRead
                  ? null
                  : Colors.blue.withValues(alpha: 0.05),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getNotificationColor(notification.type),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
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
                subtitle: Text(notification.message),
                trailing: notification.isRead
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await ref
                              .read(transactionRepositoryProvider)
                              .markNotificationAsRead(notification.id);
                          ref.invalidate(notificationsProvider);
                        },
                      ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trade_request':
        return Colors.orange;
      case 'trade_accepted':
        return Colors.green;
      case 'new_message':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trade_request':
        return Icons.swap_horiz;
      case 'trade_accepted':
        return Icons.check;
      case 'new_message':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }
}

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transactionHistoryProvider);

    return historyAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text('Aún no has completado ningún trueke.'),
          );
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.handshake, color: Colors.white),
                ),
                title: Text(transaction.productTitle),
                subtitle: Text('Tipo: ${transaction.tradeType.toUpperCase()}'),
                trailing: Text(
                  transaction.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
