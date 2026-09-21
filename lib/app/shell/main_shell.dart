import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/providers/shell_index_provider.dart';
import 'package:trueke/features/home/home_page.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/favorites/favorites_page.dart';
import 'package:trueke/features/profile/presentation/screens/profile_screen.dart';
import 'package:trueke/features/products/publish_product_page.dart';
import 'package:trueke/features/chats/presentation/chats_list_page.dart';

class MainShell extends ConsumerWidget {
  final Widget? child;

  const MainShell({super.key, this.child});

  void _navigateToPublish(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PublishProductPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellIndexProvider);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';

    final List<Widget> screens = [
      const HomePage(),
      const ChatsListPage(),
      const FavoritesPage(),
      ProfileScreen(userId: userId),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPublish(context),
        tooltip: 'Publicar Producto',
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(shellIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
