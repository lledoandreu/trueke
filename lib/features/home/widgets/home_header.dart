import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationCount = ref.watch(notificationsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Trueke App',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Badge(
          label: Text('$notificationCount'),
          child: const Icon(Icons.notifications),
        ),
      ],
    );
  }
}
