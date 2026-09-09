import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/shell_index_provider.dart';
import '../../../app/routes/app_routes.dart';
import '../../transactions/providers/transactions_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    final unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Trueke App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: unreadCount > 0
                    ? Badge.count(
                        count: unreadCount,
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.activity);
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.white),
                onPressed: () {
                  ref.read(shellIndexProvider.notifier).setIndex(1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
